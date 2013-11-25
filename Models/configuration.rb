require 'htmlentities'
require 'base64'

module Models
  
  class Configuration
    include ResultModule
    
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
        puts "http://#{@fs_ip}#{config_json['location']}"
        contents = open("http://#{@fs_ip}#{config_json['location']}") {|f| f.read }
        config = config_json['name'].gsub('.','_').gsub('-','_')
        config_list.merge!({config.to_sym => coder.encode(contents)})
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
          p "http://#{@fs_ip}#{config_json['location']}"
          contents = open("http://#{@fs_ip}#{config_json['location']}") {|f| f.read }
          config = config_json['name'].gsub('.','_').gsub('-','_')
          config_list.merge!({config.to_sym => coder.encode(contents)})
        end if config_json_list
      ensure
        store.quit
      end
      config_list
    end

  end
end
