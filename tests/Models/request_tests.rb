require './tests/Models/test_helper.rb'
require  './Models/request.rb'

class RequestTest < Test::Unit::TestCase
	def test_initialize
		request = Models::Request.new('POST', '/test', ['test'],'body')
		assert_not_nil(request, "request construction failed")
		assert_equal('POST', request.method)
		assert_equal('/test', request.uri)
		assert_equal(['test'], request.headers)		
		assert_equal('body', request.body)		
	end

	def test_initialize_default
		request = Models::Request.new
		assert_not_nil(request, "request construction failed")
		assert_equal('GET', request.method)
		assert_equal('/', request.uri)
		assert_equal([], request.headers)		
		assert_equal('', request.body)		
	end

	def test_initialize_method
		request = Models::Request.new('POST')
		assert_not_nil(request, "request construction failed")
		assert_equal('POST', request.method)
		assert_equal('/', request.uri)
		assert_equal([], request.headers)		
		assert_equal('', request.body)		
	end

	def test_initialize_uri
		request = Models::Request.new('POST','/test')
		assert_not_nil(request, "request construction failed")
		assert_equal('POST', request.method)
		assert_equal('/test', request.uri)
		assert_equal([], request.headers)		
		assert_equal('', request.body)		
	end

	def test_initialize_headers
		request = Models::Request.new('POST','/test',['test'])
		assert_not_nil(request, "request construction failed")
		assert_equal('POST', request.method)
		assert_equal('/test', request.uri)
		assert_equal(['test'], request.headers)		
		assert_equal('', request.body)		
	end
end