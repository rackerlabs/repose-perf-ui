require './tests/Models/test_helper.rb'
require  './Models/perftest.rb'

class PerfTestTest < Test::Unit::TestCase
	def test_initialize
		perftest = Models::PerfTest.new(1,2,3)
		assert_not_nil(perftest, "PerfTest construction failed")
		assert_equal(1, perftest.id)
		assert_equal(2, perftest.name)
		assert_equal(3, perftest.description)		
	end

end