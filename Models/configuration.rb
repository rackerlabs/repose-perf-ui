require 'htmlentities'
require 'base64'

module SnapshotComparer
module Models
  class Configuration

    attr_reader :db, :fs_ip

    def initialize(db, fs_ip)
      @db = db
      @fs_ip = fs_ip
    end

    def _get_result(store, application, name, test_type, id)
      config_list = {}

      coder = HTMLEntities.new
      config_json_list = store.lrange("#{application}:#{name}:results:#{test_type}:#{id}:configs", 0, -1)
      config_json_list.each do |config_json_text|
        config_json = JSON.parse(config_json_text)
        contents = open("http://#{@fs_ip}#{config_json['location']}") {|f| f.read }
        config = config_json['name'].gsub('.','_').gsub('-','_').gsub('/','_')
        puts config
        puts contents
        config_list.merge!({config.to_sym => coder.encode(contents.force_encoding('utf-8'))})
      end
      config_list
    end

    def get_result(app_type, application, name, test_type, id)
      store = Redis.new(@db)
      begin
        if app_type == :comparison
          config_list = {}
          id.split('+').each {|guid| config_list[guid] = _get_result(store, application,name,test_type, guid)}
        else
          config_list = _get_result(store, application,name,test_type, id)
        end
      ensure
        store.quit
      end
      config_list
    end

    def get_by_name(application, name)
      store = Redis.new(@db)
      config_list = {}
      begin
        coder = HTMLEntities.new
        config_json_list = store.lrange("#{application}:#{name}:setup:configs", 0, -1)
        config_json_list.each do |config_json_text|
          config_json = JSON.parse(config_json_text)
          contents = open("http://#{@fs_ip}#{config_json['location']}") {|f| f.read }
          config = config_json['name'].gsub('.','_').gsub('-','_').gsub('/','_')
          config_list.merge!({config.to_sym => coder.encode(contents)})
        end if config_json_list
      ensure
        store.quit
      end
      config_list
    end

    def add_config(application, name, storage_info, config_name, config_body)
      store = Redis.new(@db)

      existing_config = store.lrange("#{application}:#{name}:setup:configs", 0, -1).find do |config|
        config_name == JSON.parse(config)['name'] || File.basename(JSON.parse(config)['location']) == config_name
      end

      raise ArgumentError, "file already exists" if existing_config

      config_json = {
        "name" => config_name.gsub('.','_').gsub('-','_').gsub('/','_'),
        "location" => "/#{storage_info['prefix']}/#{application}/#{name}/setup/configs/#{config_name}"
      }
      begin
        if storage_info['destination'] == 'localhost'
          FileUtils.mkpath "#{storage_info['path']}/#{storage_info['prefix']}/#{application}/#{name}/setup/configs" unless File.exists?("#{storage_info['path']}/#{storage_info['prefix']}/#{application}/#{name}/setup/configs")
          File.open("#{storage_info['path']}/#{config_json['location']}", "w") do |f|
            f.write(config_body.read)
          end
        else
          tmp_dir = "/tmp/#{guid}/"
          File.open("/tmp/#{guid}/#{config_name}", "w") do |f|
            f.write(config_body.read)
          end
          FileUtils.mkpath tmp_dir unless File.exists?(tmp_dir)
          Net::SCP.upload!(
            config['storage_info']['destination'],
            config['storage_info']['user'],
            "/tmp/#{guid}/#{config_name}",
            "#{storage_info['path']}/#{config_json['location']}",
            {:recursive => true,
              :verbose => Logger::DEBUG}
          )
          FileUtils.rm_rf("/tmp/#{guid}")
        end
        store.rpush("#{application}:#{name}:setup:configs", config_json.to_json)
      end
    end

    def remove_config(application, name, storage_info, config_name)
      store = Redis.new(@db)
      actual_config = JSON.parse(store.lrange("#{application}:#{name}:setup:configs", 0, -1).find do |c|
        temp = JSON.parse(c)
        temp['name'] == config_name
      end)

      begin
        if storage_info['destination'] == 'localhost'
          FileUtils.remove_file "#{storage_info['path']}/#{actual_config['location']}"
        else
          Net::SSH.start(test_agent, 'root') do |ssh|
            ssh.exec!("rm #{storage_info['path']}/#{actual_config['location']}")
          end
        end
        store.lrem("#{application}:#{name}:setup:configs", 1, actual_config.to_json)
      end
    end
  end
end
end
