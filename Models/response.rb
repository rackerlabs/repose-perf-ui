module SnapshotComparer
module Models
	class Response
	  include Models

	  attr_reader :response_code

	  def initialize(response_code)
	    @response_code = response_code
	  end
	end
end
end
