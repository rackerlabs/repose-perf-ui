module Models
  class TestLocationFactory
    extend ResultModule
    
    attr_reader :store
    
    def initialize(db)
      @store = Redis.new(db)
    end
    

    def get_by_name(app_name, name)
      test_values = @store.hgetall("#{app_name}:#{name}:tests:setup:main:script")
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
          href = Base64.decode64(value)
        end 
      end

      return TestLocation.new(href, type)
    end

    def self.get_by_file_location(file_location)
      test_location_dir = "#{file_location}/meta"
      test_file = Dir.entries(test_location_dir).find { |file_name| file_name.start_with?("test_")}  if Dir.exists?(test_location_dir)
      raise ArgumentError, "No test file exists for #{file_location}" unless test_file
      
      case File.extname(test_file)
      when ".jmx"
        href = test_file
        type = :jmeter
      else
        raise ArgumentError, "Unknown test file for #{file_location} (#{test_file})"
      end

      return TestLocation.new(href,type,test_location_dir)
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
