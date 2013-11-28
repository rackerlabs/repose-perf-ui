require File.expand_path("Models/runner.rb", Dir.pwd)
require File.expand_path("Models/plugin.rb", Dir.pwd)

require 'yaml'
require 'redis'

module Apps
  class Bootstrap
    attr_reader :config, :db, :fs_ip, :storage_info
    @@applications ||= []
    @@test_list ||= []
    
    class << self
      attr_accessor :env
    end
    
    def self.main_config(environment)
      if environment == :production
        @env = "config/config.yaml"
      elsif environment == :test
        @env = "config/test_config.yaml"
      elsif environment == :development
        @env = "config/dev_config.yaml"
      end
    end

    def self.logger
      Logging.color_scheme( 'bright',
        :levels => {
          :info  => :green,
          :warn  => :yellow,
          :error => :red,
          :fatal => [:white, :on_red]
        },
        :date => :blue,
        :logger => :cyan,
        :message => :magenta
      )
      logger = Logging.logger(STDOUT)
      logger.level = :info
      logger
    end

    def self.load_applications
      folder_location = File.expand_path("apps", Dir.pwd)
      Dir.glob("#{folder_location}/**/bootstrap.rb").each do |entry|
        require entry unless File.directory?(entry)
      end
    end

    def self.application_list
      load_applications if @@applications.empty?
      @@applications
    end

    def self.inherited(klass)
      full_path = caller[0].partition(":")[0]
      dir_name =  File.dirname(full_path)[File.dirname(full_path).rindex('/')+1..-1]
      @@applications << {:id => dir_name, :klass => klass}
    end

    def self.runner_list
      {
        :jmeter => Models::JMeterRunner.new,
        :pravega => Models::PravegaRunner.new,
        :flood => Models::FloodRunner.new,
        :autobench => Models::AutoBenchRunner.new
      }
    end
    
    def self.backend_connect(redis_info = nil)
      if redis_info
        raise ArgumentError, "required information was not provided to connect to backend data store" unless redis_info[:host]
        port = redis_info.has_key?(:port) ? redis_info[:port] : 6379
        db_number = redis_info.has_key?(:db) ? redis_info[:db] : 1
        db = {:host => redis_info[:host], :port => port, :db => db_number}
      else
        config = YAML.load_file(File.expand_path(self.env, Dir.pwd))
        db = {:host => config['redis']['host'], :port => config['redis']['port'], :db => config['redis']['db']}
      end
      db
    end
    
    def self.backend_fs
      config = YAML.load_file(File.expand_path(self.env, Dir.pwd))
      fs_ip = config['file_store']      
    end
    
    def self.storage_info
      config = YAML.load_file(File.expand_path(self.env, Dir.pwd))
      storage_info = config['storage_info']
    end

    
    def self.initialize_results
      {
        :comparison => {
          :klass => Results::ComparisonResults.new,
          :summary_view => :comparison_summary_results,
          :detailed_view => :comparison_detailed_results,
          :plugin_view => :comparison_plugin_results
        },
        :singular => {
          :klass => Results::SingularResults.new,
          :summary_view => :singular_summary_results,
          :detailed_view => :singular_detailed_results,
          :plugin_view => :singular_plugin_results
        }
      }
    end
    
    def self.test_list()
      if @@test_list.empty?
        config = YAML.load_file(File.expand_path(self.env, Dir.pwd))
        @@test_list = config['test_list']
        logger.debug "loaded test list: #{@@test_list.inspect}"
      end
      @@test_list
    end

    def initialize(redis_info, logger)
      @logger = logger ? logger : Bootstrap.logger
      @logger.debug "loaded config: #{@config}" if @config  

      if redis_info
        raise ArgumentError, "required information missing from your storage connection." unless redis_info.has_key?(:host)
      end
      @db = Bootstrap.backend_connect(redis_info)
      @logger.debug "loaded backend: #{@db.inspect}" if @db
      @fs_ip = Bootstrap.backend_fs
      @logger.debug "loaded ip: #{@fs_ip}" if @fs_ip     
      @storage_info = Bootstrap.storage_info
      @logger.debug "loaded storage info: #{@storage_info}" if @storage_info 
    end

    def load_plugins
      raise NotImplementedError, 'Your configuration has not yet been instantiated.  The reason for that is most likely because you are calling load_plugins from Bootstrap itself instead of calling it from an application\'s bootstrap.' unless @config
      plugin_list = @config['application']['plugins']
      @logger.debug "plugin_list: #{plugin_list}"
      plugin_list.each do |plugin|
        plugin.each do |key, entry|
          @logger.debug "entry: #{entry}"
          plugin = File.expand_path(entry, Dir.pwd) 
          @logger.debug "plugin: #{plugin}" 
          require plugin unless File.directory?(plugin)
        end
      end
      Plugin.plugin_list 
    end

    def start_test_recording(application, sub_app = 'main', type = 'load', json_data = {}, timestamp = nil)
      start_time = timestamp ? timestamp : Time.now
      #store the start time in Redis
      store = Redis.new(@db)
      start_test = {} 
      begin
        raise ArgumentError, "invalid comparison guid" if json_data.has_key?('comparison_guid') and !store.lrange("#{application}:#{sub_app}:results:#{type}",0, -1).include?(json_data['comparison_guid'])
        
        id = "#{application}:test:#{sub_app}:#{type}:start"
        unless store.get(id)
          guid = SecureRandom.uuid
          start_test = {:guid => guid, :time => start_time }.merge(json_data).to_json
          store.set(id, start_test)
        end
      rescue => e
        return {"fail" => e.message}.to_json
      ensure
        store.quit
      end
      start_test 
    end

    def stop_test_recording(application, sub_app = 'main', type = 'load', json_data = nil, timestamp = nil)
      id = "#{application}:test:#{sub_app}:#{type}:start"
      store = Redis.new(@db)
      begin
        raise ArgumentError, "start time for this test was not found.  Did you forget to start the test?" unless store.get(id)
        start_test = JSON.parse(store.get(id))
        raise ArgumentError, "invalid guid" unless json_data['guid'] == start_test['guid']
        end_time = timestamp ? timestamp : Time.now
        store_data(application, sub_app, type, json_data, store, storage_info, start_test, end_time, @fs_ip)
        #load data for plugins here (from base class)
        plugins = load_plugins
        plugins.each do |plugin|
          plugin.new(@db, @fs_ip).store_data(application, sub_app, type, json_data['guid'], store, start_test['time'], end_time)
        end 
        store.del(id)
        return {"result" => "OK"}
      rescue => e
        return {"fail" => e.message}
      ensure
        FileUtils.rm_rf("/tmp/#{json_data['guid']}")
        store.quit
      end
    end
    
    
    def create_tmp_dir(guid)
      FileUtils.mkpath "/tmp/#{guid}/data"
      FileUtils.mkpath "/tmp/#{guid}/meta"
      FileUtils.mkpath "/tmp/#{guid}/configs"
    end
    
    def copy_meta_data(application, sub_app, type, store, guid, storage_info, fs_ip)
      request = store.get("#{application}:#{sub_app}:tests:setup:request_response:request")
      store.hset("#{application}:#{sub_app}:results:#{type}:#{guid}:meta", "request", request)

      response = store.get("#{application}:#{sub_app}:tests:setup:request_response:response")
      store.hset("#{application}:#{sub_app}:results:#{type}:#{guid}:meta", "response", response)

      script_info = store.hgetall("#{application}:#{sub_app}:tests:setup:script")
      raise ArgumentError, "no test script is available for #{application}-#{sub_app}" unless script_info
      script_json_info = JSON.parse(script_info['test'])
      script_result_json = {}
      script_result_json['name'] = script_json_info['name']
      script_result_json['type'] = script_info['type']
      
      script_result_json['location'] = "/#{storage_info['prefix']}/#{application}/#{sub_app}/results/#{type}/#{guid}/meta/#{script_json_info['name']}"
      
      f = open("/tmp/#{guid}/meta/#{script_result_json['name']}", 'w')
      begin
        open("http://#{fs_ip}#{script_json_info['location']}") do |resp|
          resp.each_line do |segment|
            f.write(segment)
          end
        end
      ensure
        f.close()
      end
      
      result = script_result_json.to_json
      store.hset("#{application}:#{sub_app}:results:#{type}:#{guid}:meta", "script", result)

      runner_data = store.hget("#{application}:#{sub_app}:tests:setup:test", script_result_json['type'])
      store.hset("#{application}:#{sub_app}:results:#{type}:#{guid}:meta", "test_#{script_result_json['type']}", runner_data)
    end
    
    def copy_meta_test(application, sub_app, type, json_data, start_test, end_time, runner, store)
      test_info = store.hget("#{application}:#{sub_app}:tests:setup:test", "common")
      if test_info
        test_json_info = JSON.parse(test_info)
      else
        test_json_info = {}
      end
      
      test_json_info['runner'] = runner
      test_json_info['start'] = start_test['time']
      test_json_info['stop'] = end_time
      test_json_info['description'] = start_test['description']
      test_json_info['name'] = start_test['name']
      test_json_info['comparison_guid'] = start_test['comparison_guid'] if start_test['comparison_guid']
      
      test_json_info_result = test_json_info.to_json

      store.hset("#{application}:#{sub_app}:results:#{type}:#{json_data['guid']}:meta", "test", test_json_info_result)
    end
        
    def store_data(application, sub_app, type, json_data, store, storage_info, start_test, end_time, fs_ip)
      store.rpush("#{application}:#{sub_app}:results:#{type}", json_data['guid'])
      create_tmp_dir(json_data['guid'])
      copy_meta_data(application, sub_app, type, store, json_data['guid'], storage_info, fs_ip)
=begin
 create results, meta, data directories in /tmp/#{guid} directory -- DONE
 move the following data directly into application:sub_app:results:type:guid:meta: (NEED application, sub_app, type, json_data)
 - request -- DONE
 - response -- DONE
 - script  -- DONE
 - test_runner  -- DONE
 copy script to /application/sub_app/results/type/guid/meta folder (NEED application, sub_app, type, json_data) -- DONE
 update the following data with the values coming from the start_test entry
 - application:sub_app:results:type:guid:meta test (NEED application, sub_app, type, json_data, start_test, end_time)
=end      
      copy_meta_test(application, sub_app, type, json_data, start_test, end_time, start_test['runner'], store)
            
      source_result_info = json_data['servers']['results']
      runner = Apps::Bootstrap.runner_list[start_test['runner'].to_sym]
      runner.store_results(application, sub_app, type, json_data['guid'], source_result_info, storage_info, store)
      
      source_config_info = json_data['servers']['config']
      copy_configs(application, sub_app, type, json_data['guid'], source_config_info, storage_info, store) if source_config_info
      
      Net::SCP.upload!(
        storage_info['destination'], 
        storage_info['user'], 
        "/tmp/#{json_data['guid']}", 
        "#{storage_info['path']}/#{storage_info['prefix']}/#{application}/#{sub_app}/results/#{type}", 
        {:recursive => true, :verbose => true }
      )
      
    end
    
    def copy_configs(application, sub_app, type, guid, source_config_info, storage_info, store)
=begin
 get configs from user's servers.config 
 add entry application:sub_app:results:type:guid:configs with the json path
=end  
      Net::SCP.download!(
        source_config_info['server'], 
        source_config_info['user'], 
        source_config_info['path'], 
        "/tmp/#{guid}/configs/", 
        {:recursive => true,
          :verbose => :debug}
      ) 
      
      #iterate through configs and add to redis
      Dir.glob("/tmp/#{guid}/configs/**/*") do |entry|
        unless File.directory?(entry)
          test = entry.sub(/^\/tmp\/#{Regexp.escape(guid)}\/configs\//,'')
          entry_hash = {}
          entry_hash['name'] = File.basename(entry)
          entry_hash['location'] = "/#{storage_info['prefix']}/#{application}/#{sub_app}/results/#{type}/#{guid}/configs/#{test}"
          result = entry_hash.to_json
          store.rpush("#{application}:#{sub_app}:results:#{type}:#{guid}:configs", result)
        end
      end
    end    
  end
end
