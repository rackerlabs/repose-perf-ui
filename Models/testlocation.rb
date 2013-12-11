module Models
  class TestLocationFactory
    extend ResultModule
    
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
