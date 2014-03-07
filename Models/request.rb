module SnapshotComparer
module Models
	class Request

	  attr_reader :method, :uri, :headers, :body

	  def initialize(method = "GET" ,uri = "/" ,headers = [],body = "")
	    @method = method
	    @uri = uri
	    @headers = headers
	    @body = body
	  end
	end
end
end
