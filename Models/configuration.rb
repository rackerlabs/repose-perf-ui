require 'htmlentities'
require 'base64'

module Models
  
  class Configuration
    include ResultModule
    
    attr_reader :store, :fs_ip
    
    def initialize(db, fs_ip)
      @store = Redis.new(db)
      @fs_ip = fs_ip
    end

    def get_result(application, name, test_type, id)
      coder = HTMLEntities.new
      config_list = {}
      config_json_list = @store.lrange("#{application}:#{name}:results:#{test_type}:#{id}:configs", 0, -1)
      config_json_list.each do |config_json_text|
        config_json = JSON.parse(config_json_text)
        puts "http://#{@fs_ip}#{config_json['location']}"
        contents = open("http://#{@fs_ip}#{config_json['location']}") {|f| f.read }
        config = config_json['name'].gsub('.','_').gsub('-','_')
        config_list.merge!({config.to_sym => coder.encode(contents)})
      end
      config_list
    end

    def get_by_name(application, name)
      coder = HTMLEntities.new
      config_list = {}
      config_json_list = @store.lrange("#{application}:#{name}:setup:configs", 0, -1)
      config_json_list.each do |config_json_text|
        config_json = JSON.parse(config_json_text)
        p "http://#{@fs_ip}#{config_json['location']}"
        contents = open("http://#{@fs_ip}#{config_json['location']}") {|f| f.read }
        config = config_json['name'].gsub('.','_').gsub('-','_')
        config_list.merge!({config.to_sym => coder.encode(contents)})
      end if config_json_list
      config_list
    end

  end
end
