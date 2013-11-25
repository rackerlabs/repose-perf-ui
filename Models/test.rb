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
    
    attr_reader :db
    
    def initialize(db)
      @db = db
    end
    
    def _get_result_requests(store, application, name, test_type, id)
      response = []
      puts "#{application}:#{name}:results:#{test_type}:#{id}:meta"
      requests = store.hget("#{application}:#{name}:results:#{test_type}:#{id}:meta", "request")
      responses = store.hget("#{application}:#{name}:results:#{test_type}:#{id}:meta", "response")
      request_list = []
      response_list = [] 
      coder = HTMLEntities.new
    
      requests_json = JSON.parse(requests) if requests
      responses_json = JSON.parse(responses) if responses
    
      if requests_json and responses_json
        requests_json.each do |request|
          request_list << Request.new(request["method"], request["uri"], request["headers"], coder.encode(request["body"]))
        end
      
        responses_json.each do |response|
          response_list << Response.new(response["response_code"])        
        end

        response = request_list.zip(response_list)
      else
        raise ArgumentError, "required requests and response jsons are not available.  These files are required to let users know what execution happens during a test run."
      end
      response
    end
      
    def get_result_requests(app_type, application, name, test_type, id)
      store = Redis.new(@db)
      begin
        if app_type == :comparison
          results = {}
          id.split('+').each {|guid| results[guid] = _get_result_requests(store, application, name, test_type, guid)}
        else
          results = []
          results = _get_result_requests(store, application, name, test_type, id)
        end
      ensure
        store.quit
      end
      results
    end

    def get_setup_requests_by_name(application, name)
      response = []
      store = Redis.new(@db)
      begin
        requests = store.get("#{application}:#{name}:tests:setup:request_response:request")
        responses = store.get("#{application}:#{name}:tests:setup:request_response:response")
        request_list = []
        response_list = [] 
        coder = HTMLEntities.new
      
        requests_json = JSON.parse(requests) if requests
        responses_json = JSON.parse(responses) if responses
      
        if requests_json and responses_json
          requests_json.each do |request|
            request_list << Request.new(request["method"], request["uri"], request["headers"], coder.encode(request["body"]))
          end
        
          responses_json.each do |response|
            response_list << Response.new(response["response_code"])        
          end
  
          response = request_list.zip(response_list)
        else
          raise ArgumentError, "required requests and response jsons are not available.  These files are required to let users know what execution happens during a test run."
        end
      ensure
        store.quit
      end
      response
    end

    def get_runner_by_name_test(name,test)
      test_contents = File.read("#{config['home_dir']}/files/apps/#{name}/tests/setup/main/#{test}_test.json") if File.exists?("#{config['home_dir']}/files/apps/#{name}/tests/setup/main/#{test}_test.json") 
      test_json = JSON.parse(test_contents) if test_contents && test_contents.is_json?
      test_json['runner']
    end
    
  end
end
