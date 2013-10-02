require_relative  'request.rb'
require_relative  'response.rb'
require 'htmlentities'

class String
  def is_json?
    begin
      !!JSON.parse(self)
    rescue
      false
    end
  end
end

module Models
  class Test
    include ResultModule

    def get_results_requests_by_file_location(test_location)
      request_text = File.read("#{test_location}/meta/request.json")  if File.exists?("#{test_location}/meta/request.json") 
      response_text = File.read("#{test_location}/meta/response.json") if File.exists?("#{test_location}/meta/response.json")
      request_json = JSON.parse(request_text) if request_text && request_text.is_json?
      response_json = JSON.parse(response_text) if response_text && response_text.is_json?
      request_list = []
      response_list = [] 
      coder = HTMLEntities.new
      request_json["tests"].each do |request|
        request_list << Models::Request.new(request["method"], request["uri"], request["headers"], coder.encode(request["body"]))
      end if request_json
      response_json["tests"].each do |response|
        response_list << Models::Response.new(response["response_code"])
      end if response_json

      request_list.zip(response_list)

    end

    def get_setup_requests_by_name(name)
      request_text = File.read("#{config['home_dir']}/files/apps/#{name}/tests/setup/main/request.json")  if File.exists?("#{config['home_dir']}/files/apps/#{name}/tests/setup/main/request.json") 
      response_text = File.read("#{config['home_dir']}/files/apps/#{name}/tests/setup/main/response.json") if File.exists?("#{config['home_dir']}/files/apps/#{name}/tests/setup/main/response.json")
      request_json = JSON.parse(request_text) if request_text && request_text.is_json?
      response_json = JSON.parse(response_text) if response_text && response_text.is_json?
      request_list = []
      response_list = [] 
      coder = HTMLEntities.new
      request_json["tests"].each do |request|
        request_list << Request.new(request["method"], request["uri"], request["headers"], coder.encode(request["body"]))
      end if request_json
      response_json["tests"].each do |response|
        response_list << Response.new(response["response_code"])
      end if response_json

      request_list.zip(response_list)
    end
    
  end
end