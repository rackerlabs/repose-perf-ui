require './tests/Models/test_helper.rb'
require  './Models/application.rb'

class ApplicationTest < Test::Unit::TestCase
	def test_initialize
		application = Models::Application.new(1,2,3)
		assert_not_nil(application, "Application construction failed")
		assert_equal(1, application.id)
		assert_equal(2, application.name)
		assert_equal(3, application.description)		
	end

end