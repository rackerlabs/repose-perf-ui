require 'htmlentities'
class Test
  include Models
 
  attr_reader :test_list
  
  def initialize(name)
    request_json = JSON.parse(File.read("/root/repose/dist/files/apps/#{name}/tests/main/request.json"))
    response_json = JSON.parse(File.read("/root/repose/dist/files/apps/#{name}/tests/main/response.json"))
    request_list = []
    response_list = [] 
    coder = HTMLEntities.new
    request_json["tests"].each do |request|
      request_list << Request.new(request["method"], request["uri"], request["headers"], coder.encode(request["body"]))
    end
    response_json["tests"].each do |response|
      response_list << Response.new(response["response_code"])
    end

    @test_list = request_list.zip(response_list)
  end
  
end
