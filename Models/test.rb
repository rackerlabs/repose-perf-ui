require_relative  'request.rb'
require_relative  'response.rb'
require 'htmlentities'
require 'redis'

module SnapshotComparer
  module Models
  class Test

    attr_reader :db

    def initialize(db)
      @db = db
    end

    def _get_result_requests(store, application, name, test_type, id)
      response = []
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

    def add_request_response(application, name, storage_info, request, response)
      store = Redis.new(@db)
      request_id_list = store.get("#{application}:#{name}:tests:setup:request_response:request")
      response_id_list = store.get("#{application}:#{name}:tests:setup:request_response:response")

      if request_id_list
        request_list = JSON.parse(request_id_list)
        request_id = request_list.map {|r| r['request_id']}.max + 1
      else
        request_list = []
        request_id = 1
      end

      request['request_id'] = request_id

      request_list << request

      if response_id_list
        response_list = JSON.parse(response_id_list)
      else
        response_list = []
      end

      response['request_id'] = request_id
      response_list << response

      begin
        store.set("#{application}:#{name}:tests:setup:request_response:request", request_list.to_json)
        store.set("#{application}:#{name}:tests:setup:request_response:response", response_list.to_json)
      end
    end

    def update_request_response(application, name, storage_info, request, response)
      store = Redis.new(@db)
      request_id_list = JSON.parse(store.get("#{application}:#{name}:tests:setup:request_response:request"))
      response_id_list = JSON.parse(store.get("#{application}:#{name}:tests:setup:request_response:response"))

      request_list = request_id_list.delete_if {|r| r['request_id'].to_i == request['request_id'].to_i }
      response_list = response_id_list.delete_if {|r| r['request_id'].to_i == response['request_id'].to_i }

      request_list << request
      response_list << response

      begin
        store.set("#{application}:#{name}:tests:setup:request_response:request", request_list.to_json)
        store.set("#{application}:#{name}:tests:setup:request_response:response", response_list.to_json)
      end
    end

    def remove_request_response(application, name, storage_info, request_ids)
      store = Redis.new(@db)
      request_id_list = JSON.parse(store.get("#{application}:#{name}:tests:setup:request_response:request"))
      response_id_list = JSON.parse(store.get("#{application}:#{name}:tests:setup:request_response:response"))

      request_list = request_id_list.delete_if {|r| request_ids.include?(r['request_id'].to_s) }
      response_list = response_id_list.delete_if {|r| request_ids.include?(r['request_id'].to_s) }

      begin
        store.set("#{application}:#{name}:tests:setup:request_response:request", request_list.to_json)
        store.set("#{application}:#{name}:tests:setup:request_response:response", response_list.to_json)
      end
    end
  end
end
end
