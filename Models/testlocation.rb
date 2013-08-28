class TestLocationFactory

  def self.get_by_name(app_name)
    test_location_dir = "/root/repose/dist/files/apps/#{app_name}/tests/setup/main"
    test_file = Dir.entries(test_location_dir).find { |file_name| file_name.start_with?("test_")} 
    raise "No test file exists for #{app_name}" unless test_file
    
    case File.extname(test_file)
    when ".jmx"
      href = test_file
      type = :jmeter
    else
      raise "Unknown test file for #{app_name} (#{test_file})"
    end

    return TestLocation.new(href,type,test_location_dir)
  end

  def self.get_by_file_location(file_location)
    test_location_dir = "#{file_location}/meta"
    test_file = Dir.entries(test_location_dir).find { |file_name| file_name.start_with?("test_")} 
    raise "No test file exists for #{app_name}" unless test_file
    
    case File.extname(test_file)
    when ".jmx"
      href = test_file
      type = :jmeter
    else
      raise "Unknown test file for #{app_name} (#{test_file})"
    end

    return TestLocation.new(href,type,test_location_dir)
  end

  def download
    "#{@test_location_dir}/#{@href}"
  end
end

class TestLocation
  include Models

  attr_reader :href, :type, :test_location_dir 
  
  def initialize(href,type,location)
    @href = href
    @type = type
    @test_location_dir = location
  end
end
