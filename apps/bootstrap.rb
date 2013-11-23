require File.expand_path("Models/runner.rb", Dir.pwd)
require File.expand_path("Models/plugin.rb", Dir.pwd)

require 'yaml'
require 'redis'

module Apps
  class Bootstrap
    attr_reader :config, :db, :fs_ip
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
      logger.level = :debug
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

    def start_test_recording(id, timestamp = nil)
      start_time = timestamp ? timestamp : Time.now
      #store the start time in Redis
      {:response => Redis.new(@db).set(id, start_time), :time => start_time} 
    end

    def stop_test_recording(id, timestamp = nil)
      start_time = Redis.new(@db).get(id)
      raise ArgumentError, "start time for this test was not found.  Did you forget to start the test?" unless start_time
      end_time = timestamp ? timestamp : Time.now
      #load data for plugins here (from base class)
      plugins = load_plugins
      plugins.each do |plugin|
        plugin.new.store_data(Redis.new(@db), start_time, end_time)
      end 
      Redis.new(@db).del(id)
      "OK"
    end
  end
end
