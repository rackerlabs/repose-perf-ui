require 'htmlentities'

class Configuration
  include Models
 
  attr_reader :config_location
  attr_reader :config_list

  def initialize(name)
    coder = HTMLEntities.new
    @config_location = "/root/repose/dist/files/apps/#{name}/configs/main/" 
    @config_list = {}
    Dir.entries(@config_location).find_all { |file_name| file_name.include?(".xml")}.each do |file_name|
      config = file_name.gsub('.','_').gsub('-','_')
      contents = File.read("#{@config_location}/#{file_name}")
      @config_list.merge!({config.to_sym => coder.encode(contents)})
    end
  end

end
