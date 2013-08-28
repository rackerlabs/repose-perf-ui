require 'htmlentities'
class Test
  include Models
 
  def get_requests_by_file_location(test_location)
    request_json = JSON.parse(File.read("#{test_location}/meta/request.json"))
    response_json = JSON.parse(File.read("#{test_location}/meta/response.json"))
    request_list = []
    response_list = [] 
    coder = HTMLEntities.new
    request_json["tests"].each do |request|
      request_list << Request.new(request["method"], request["uri"], request["headers"], coder.encode(request["body"]))
    end
    response_json["tests"].each do |response|
      response_list << Response.new(response["response_code"])
    end

    request_list.zip(response_list)

  end

  def get_requests_by_name(name)
    request_json = JSON.parse(File.read("/root/repose/dist/files/apps/#{name}/tests/setup/main/request.json"))
    response_json = JSON.parse(File.read("/root/repose/dist/files/apps/#{name}/tests/setup/main/response.json"))
    request_list = []
    response_list = [] 
    coder = HTMLEntities.new
    request_json["tests"].each do |request|
      request_list << Request.new(request["method"], request["uri"], request["headers"], coder.encode(request["body"]))
    end
    response_json["tests"].each do |response|
      response_list << Response.new(response["response_code"])
    end

    request_list.zip(response_list)
  end
  
end
