require 'htmlentities'

module Models
  
  class Configuration
    include ResultModule

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

    def get_by_name(name)
      coder = HTMLEntities.new
      config_location = "#{config['home_dir']}/files/apps/#{name}/configs/main/" 
      config_list = {}
      Dir.entries(config_location).find_all { |file_name| file_name.include?(".xml")}.each do |file_name|
        config = file_name.gsub('.','_').gsub('-','_')
        contents = File.read("#{config_location}/#{file_name}")
        config_list.merge!({config.to_sym => coder.encode(contents)})
      end if Dir.exists?(config_location)
      config_list
    end

  end
end
