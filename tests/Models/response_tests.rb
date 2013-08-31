require './tests/Models/test_helper.rb'
require  './Models/response.rb'

class ResponseTest < Test::Unit::TestCase
	def test_initialize
		response = Models::Response.new(201)
		assert_not_nil(response, "Response construction failed")
		assert_equal(201, response.response_code)
	end

	def test_initialize_nil
		assert_raise ArgumentError do
			response = Models::Response.new
		end
	end
end