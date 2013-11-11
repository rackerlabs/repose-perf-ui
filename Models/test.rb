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

    def get_result_requests(application, name, test_type, id)
      requests = @store.hget("#{application}:#{name}:results:#{test_type}:#{id}:meta", "request")
      responses = @store.hget("#{application}:#{name}:results:#{test_type}:#{id}:meta", "response")
      request_list = []
      response_list = [] 
      coder = HTMLEntities.new
      
      requests_json = JSON.parse(requests) if requests
      responses_json = JSON.parse(responses) if responses
      
      requests_json.each do |request|
        request_list << Request.new(request["method"], request["uri"], request["headers"], coder.encode(request["body"]))
      end
      
      responses_json.each do |response|
        response_list << Response.new(response["response_code"])        
      end

      request_list.zip(response_list)
    end

    def get_setup_requests_by_name(application, name)
      requests = @store.get("#{application}:#{name}:tests:setup:request_response:request")
      responses = @store.get("#{application}:#{name}:tests:setup:request_response:response")
      request_list = []
      response_list = [] 
      coder = HTMLEntities.new
      
      requests_json = JSON.parse(requests) if requests
      responses_json = JSON.parse(responses) if responses
      
      requests_json.each do |request|
        request_list << Request.new(request["method"], request["uri"], request["headers"], coder.encode(request["body"]))
      end
      
      responses_json.each do |response|
        response_list << Response.new(response["response_code"])        
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