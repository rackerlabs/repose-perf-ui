require 'htmlentities'
require 'base64'

module Models
  
  class Configuration
    include ResultModule
    
    attr_reader :store
    
    def initialize(db)
      @store = Redis.new(db)
    end

    def get_by_result_file_location(test_location)
      coder = HTMLEntities.new
      config_location = "#{test_location}/configs/" 
      config_list = {}
      Dir.entries(config_location).find_all { |file_name| file_name.include?(".xml")}.each do |file_name|
        config = file_name.gsub('.','_').gsub('-','_')
        contents = File.read("#{config_location}/#{file_name}")
        config_list.merge!({config.to_sym => coder.encode(contents)})
      end if Dir.exists?(config_location)
      config_list
    end

    def get_by_name(application, name)
      coder = HTMLEntities.new
      config_list = {}
      config_json_list = @store.lrange("#{application}:#{name}:configs:main", 0, -1)
      config_json_list.each do |config_json_text|
        config_json = JSON.parse(config_json_text)
        contents = Base64.decode64(config_json['data'])
        config = config_json['name'].gsub('.','_').gsub('-','_')
        config_list.merge!({config.to_sym => coder.encode(contents)})
      end
      config_list
    end

  end
end
