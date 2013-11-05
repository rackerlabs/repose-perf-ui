require_relative  'request.rb'
require_relative  'response.rb'
require 'htmlentities'
require 'redis'

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
    
    attr_reader :store
    
    def initialize(db)
      @store = Redis.new(db)
    end

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

    def get_setup_requests_by_name(application, name)
      request_responses = @store.hgetall("#{application}:#{name}:tests:setup:main:request_response")
      request_list = []
      response_list = [] 
      coder = HTMLEntities.new
      request_responses.each do |key, value|
        if key.include?("request")
          request = JSON.parse(value) 
          request_list << Request.new(request["method"], request["uri"], request["headers"], coder.encode(request["body"]))
        end
        if key.include?("response")
          response = JSON.parse(value)  
          response_list << Response.new(response["response_code"])
        end
      end
      request_list.zip(response_list)
    end

    def get_runner_by_name_test(name,test)
      test_contents = File.read("#{config['home_dir']}/files/apps/#{name}/tests/setup/main/#{test}_test.json") if File.exists?("#{config['home_dir']}/files/apps/#{name}/tests/setup/main/#{test}_test.json") 
      test_json = JSON.parse(test_contents) if test_contents && test_contents.is_json?
      test_json['runner']
    end
    
  end
end