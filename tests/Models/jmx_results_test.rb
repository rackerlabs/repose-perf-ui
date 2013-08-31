require './tests/Models/test_helper.rb'
require  './Models/results.rb'

class PastJmxResultsTest < Test::Unit::TestCase

	def test_construction_for_invalid_app
		jmx_results = Results::PastJmxResults.new("invalid_unit_test","adhoc")
		assert_not_nil(jmx_results, "Jmx results construction failed.")
		assert_equal(jmx_results.test_list.length, 0, "Test list returned #{jmx_results.test_list.size} results")
	end

	def test_construction_for_invalid_test_type
		jmx_results = Results::PastJmxResults.new("unit_test","unit_test_type")
		assert_not_nil(jmx_results, "Jmx results construction failed.")
		assert_equal(jmx_results.test_list.length, 0, "Test list returned #{jmx_results.test_list.size} results")
	end

	def test_construction_with_custom_config
		jmx_results = Results::PastJmxResults.new("unit_test","unit_test_type","./config/config.yaml")
		assert_not_nil(jmx_results, "Jmx results construction failed.")
		assert_equal(jmx_results.test_list.length, 0, "Test list returned #{jmx_results.test_list.size} results")
	end

	def test_construction_with_custom_invalid_config
		jmx_results = Results::PastJmxResults.new("unit_test","unit_test_type","this_is_random.yaml")
		assert_not_nil(jmx_results, "Jmx results construction failed.")
		assert_equal(jmx_results.test_list.length, 0, "Test list returned #{jmx_results.test_list.size} results")
	end

	def test_construction
		jmx_results = Results::PastJmxResults.new("unit_test","adhoc")
		assert_not_nil(jmx_results, "Jmx results construction failed.")
		assert_equal(jmx_results.test_list.length, 2, "Test list returned #{jmx_results.test_list.size} results")
	end

	def test_server_list
		jmx_results = Results::PastJmxResults.new("unit_test","adhoc")
		assert_not_nil(jmx_results, "Jmx results construction failed.")
		assert_equal(jmx_results.test_list.length, 2, "Test list returned #{jmx_results.test_list.size} results")
		assert_equal(jmx_results.test_list[0].length, 2, "Returned #{jmx_results.test_list[0].length} file entries")
		assert_equal(jmx_results.test_list[1].length, 0, "Returned #{jmx_results.test_list[1].length} file entries")
	end

	def test_server_names
		jmx_results = Results::PastJmxResults.new("unit_test","adhoc")
		assert_not_nil(jmx_results, "Jmx results construction failed.")
		assert_equal(jmx_results.test_list[0][0][:name], "jmxdata.out_test_repose_server0", "Test name = #{jmx_results.test_list[0][0][:name]}")
		assert_equal(jmx_results.test_list[0][1][:name], "jmxdata.out_test_repose_server1", "Test name = #{jmx_results.test_list[0][1][:name]}")
	end

	def test_server_categories
		jmx_results = Results::PastJmxResults.new("unit_test","adhoc")
		assert_not_nil(jmx_results, "Jmx results construction failed.")
		assert_equal(jmx_results.test_list[0][0].keys - [:name, :gc, :memory, :memoryimpl, :os, :threading], [])
		assert_equal(jmx_results.test_list[0][1].keys - [:name, :gc, :memory, :memoryimpl, :os, :threading], [])
	end



end
