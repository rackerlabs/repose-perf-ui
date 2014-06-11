require 'json'

module SnapshotComparer
module Models
  class TestLocationFactory

    attr_reader :db, :fs_ip

    def initialize(db, fs_ip)
      @db = db
      @fs_ip = fs_ip
    end


    def get_by_name(app_name, name)
      response_list = []
      store = Redis.new(@db)
      begin
        test_script_list = store.lrange("#{app_name}:#{name}:tests:setup:script", 0, -1)
        test_script_list.each do |test_script|
          test_script_json = JSON.parse(test_script)
          type = "#{test_script_json['type']}_#{test_script_json['test']}".to_sym
          href = open("http://#{@fs_ip}#{test_script_json['location']}") {|f| f.read }
          response_list << TestLocation.new(href, type)
        end
      ensure
        store.quit
      end
      response_list
    end

    def get_by_id(app_name, name, id)
      response = nil
      store = Redis.new(@db)
      begin
        test_script_list = store.lrange("#{app_name}:#{name}:tests:setup:script", 0, -1)
        test_script_list.each do |test_script|
          test_script_json = JSON.parse(test_script)
          type = "#{test_script_json['type']}_#{test_script_json['test']}".to_sym
          href = open("http://#{@fs_ip}#{test_script_json['location']}") {|f| f.read }
          if type == id.to_sym
            response = TestLocation.new(href, type)
          end
        end
      ensure
        store.quit
      end
      response
    end

    def get_result(app_type, application, name, test_type, id)
      store = Redis.new(@db)
      begin
        if app_type == :comparison
          response = {}
          id.split('+').each{|guid| response[guid] = _get_result(store, application, name, test_type, guid)}
        else
          response = _get_result(store, application, name, test_type, id)
        end
      ensure
        store.quit
      end
      response
    end

    def get_result_by_id(application, name, test_type, id)
      store = Redis.new(@db)
      begin
        response = _get_result(store, application, name, test_type, id)
      ensure
        store.quit
      end
      response
    end

    def _get_result(store, application, name, test_type, id)
      response = nil
      script = store.hget("#{application}:#{name}:results:#{test_type}:#{id}:meta", "script")
      raise ArgumentError, "No test file exists for #{application} and #{name}" unless script
      href, type = ''
      script_json = JSON.parse(script)
      case script_json['type']
      when "jmeter"
        type = :jmeter
      else
        raise ArgumentError, "Unknown test file for #{app_name} (#{test_file})"
      end
      href = open("http://#{@fs_ip}#{script_json['location']}") {|f| f.read }

      response = TestLocation.new(href, type)
    end

    def add_test_file(application, name, storage_info, test_file_name, test_file_body, test_file_runner, test_file_type)
      store = Redis.new(@db)
      test_file_json = {
        "type" => test_file_runner,
        "test" => test_file_type.chomp('_test'),
        "name" => test_file_name,
        "location" => "/#{storage_info['prefix']}/#{application}/#{name}/setup/meta/#{test_file_name}"
      }
      begin
        if storage_info['destination'] == 'localhost'
          FileUtils.mkpath "#{storage_info['path']}/#{storage_info['prefix']}/#{application}/#{name}/setup/meta" unless File.exists?("#{storage_info['path']}/#{storage_info['prefix']}/#{application}/#{name}/setup/meta")
          File.open("#{storage_info['path']}/#{test_file_json['location']}", "w") do |f|
            f.write(test_file_body.read)
          end
        else
          tmp_dir = "/tmp/#{guid}/"
          File.open("/tmp/#{guid}/#{test_file_name}", "w") do |f|
            f.write(test_file_body.read)
          end
          FileUtils.mkpath tmp_dir unless File.exists?(tmp_dir)
          Net::SCP.upload!(
            config['storage_info']['destination'],
            config['storage_info']['user'],
            "/tmp/#{guid}/#{test_file_name}",
            "#{storage_info['path']}/#{test_file_json['location']}",
            {:recursive => true,
              :verbose => Logger::DEBUG}
          )
          FileUtils.rm_rf("/tmp/#{guid}")
        end
        store.rpush("#{application}:#{name}:tests:setup:script", test_file_json.to_json)
      end
    end

    def remove_test_file(application, name, storage_info, test_file_name)
      store = Redis.new(@db)
      runner = test_file_name.split('_')[0]
      test_type = test_file_name.split('_')[1]

      test_json = store.lrange("#{application}:#{name}:tests:setup:script", 0, -1).find do |test|
        JSON.parse(test)['type'] == runner && JSON.parse(test)['test'] == test_type
      end
      if test_json
        begin
          test_hash = JSON.parse(test_json)
          if storage_info['destination'] == 'localhost'
            FileUtils.remove_file "#{storage_info['path']}/#{test_hash['location']}"
          else
            Net::SSH.start(test_agent, 'root') do |ssh|
              ssh.exec!("rm #{storage_info['path']}/#{test_hash['location']}")
            end
          end
          store.lrem("#{application}:#{name}:tests:setup:script", 1, test_json)
        end
      end
    end
  end

  class TestLocation
    include Models

    attr_reader :href, :type

    def initialize(href,type)
      @href = href
      @type = type
    end

    def download
      @href
    end
  end
end
end
