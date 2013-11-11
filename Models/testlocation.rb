module Models
  class TestLocationFactory
    extend ResultModule
    
    attr_reader :store, :fs_ip
    
    def initialize(db, fs_ip)
      @store = Redis.new(db)
      @fs_ip = fs_ip
    end
    

    def get_by_name(app_name, name)
      test_values = @store.hgetall("#{app_name}:#{name}:tests:setup:script")
      raise ArgumentError, "No test file exists for #{app_name} and #{name}" unless test_values
      href, type = ''
      test_values.each do |key, value|
        if key.include?("type")
          case value
          when "jmeter"
            type = :jmeter
          else
            raise ArgumentError, "Unknown test file for #{app_name} (#{test_file})"
          end
        end 
        if key.include?("test")
          location = JSON.parse(value)
          href = open("http://#{@fs_ip}#{location['location']}") {|f| f.read }
        end 
      end

      return TestLocation.new(href, type)
    end

    def get_result(application, name, test_type, id)
      script = @store.hget("#{application}:#{name}:results:#{test_type}:#{id}:meta", "script")
      raise ArgumentError, "No test file exists for #{app_name} and #{name}" unless script
      href, type = ''
      script_json = JSON.parse(script)
      case script_json['type']
      when "jmeter"
        type = :jmeter
      else
        raise ArgumentError, "Unknown test file for #{app_name} (#{test_file})"
      end
      href = open("http://#{@fs_ip}#{script_json['location']}") {|f| f.read }

      return TestLocation.new(href, type)
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
