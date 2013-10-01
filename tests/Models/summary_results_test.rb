require './tests/Models/test_helper.rb'
require  './Models/results.rb'

class PastSummaryResultsTest < Test::Unit::TestCase

	def test_construction_for_invalid_app
		summary_results = Results::PastSummaryResults.new("invalid_unit_test","adhoc")
		assert_not_nil(summary_results, "Summary results construction failed.")
		assert_equal(summary_results.test_list.length, 0, "Test list returned #{summary_results.test_list.size} results")
	end

	def test_construction_for_invalid_test_type
		summary_results = Results::PastSummaryResults.new("unit_test","unit_test_type")
		assert_not_nil(summary_results, "Summary results construction failed.")
		assert_equal(summary_results.test_list.length, 0, "Test list returned #{summary_results.test_list.size} results")
	end

	def test_construction_with_custom_config
		summary_results = Results::PastSummaryResults.new("unit_test","unit_test_type","./config/config.yaml")
		assert_not_nil(summary_results, "Summary results construction failed.")
		assert_equal(summary_results.test_list.length, 0, "Test list returned #{summary_results.test_list.size} results")
	end

	def test_construction_with_custom_invalid_config
		summary_results = Results::PastSummaryResults.new("unit_test","unit_test_type","this_is_random.yaml")
		assert_not_nil(summary_results, "Summary results construction failed.")
		assert_equal(summary_results.test_list.length, 0, "Test list returned #{summary_results.test_list.size} results")
	end

	def test_construction
		summary_results = Results::PastSummaryResults.new("unit_test","adhoc")
		assert_not_nil(summary_results, "Summary results construction failed.")
		assert_equal(summary_results.test_list.length, 2, "Test list returned #{summary_results.test_list.size} results")
	end

	def test_summary_keys
		summary_results = Results::PastSummaryResults.new("unit_test","adhoc")
		assert_not_nil(summary_results, "Summary results construction failed.")
		assert_equal(summary_results.test_list[0].keys - 
			['node_count', 'runner','start','stop','tag','id',
				:length,:throughput,:average,:errors,:folder_name], [])
	end

	def test_summary_values
		summary_results = Results::PastSummaryResults.new("unit_test","adhoc")
		assert_not_nil(summary_results, "Summary results construction failed.")
		assert_equal(summary_results.test_list[0]['node_count'], 2)
		assert_equal(summary_results.test_list[0]['runner'], "jmeter")
		assert_equal(summary_results.test_list[0]['start'], "1377793196000")
		assert_equal(summary_results.test_list[0]['stop'], "1377796796000")
		assert_equal(summary_results.test_list[0]['tag'], "test with connection pool against Kushala's branch. via repose")
		assert_equal(summary_results.test_list[0]['id'], "jenkins-repose-pt-static-adhoc-155")
		assert_equal(summary_results.test_list[0][:length], "3599")
		assert_equal(summary_results.test_list[0][:throughput], "954.6")
		assert_equal(summary_results.test_list[0][:average], "41")
		assert_equal(summary_results.test_list[0][:errors], "0")
		assert_equal(summary_results.test_list[0][:folder_name], "/Users/dimi5963/projects/repose_pt/files/apps/unit_test/results/adhoc/tmp_20130829T172012")
	end

	def test_detailed_results_file_location
		summary_results = Results::PastSummaryResults.new("unit_test","adhoc")
		assert_not_nil(summary_results, "Summary results construction failed.")
		results_file = summary_results.detailed_results_file_location("jenkins-repose-pt-static-adhoc-155")
		assert_equal(results_file,"/Users/dimi5963/projects/repose_pt/files/apps/unit_test/results/adhoc/tmp_20130829T172012")
	end

	def test_detailed_results_file_location_not_exists
		summary_results = Results::PastSummaryResults.new("unit_test","adhoc")
		assert_not_nil(summary_results, "Summary results construction failed.")
		assert_raise(RuntimeError, "Id not found") do
  			summary_results.detailed_results_file_location("not_found")
		end
	end

	def test_detailed_results
		summary_results = Results::PastSummaryResults.new("unit_test","adhoc")
		assert_not_nil(summary_results, "Summary results construction failed.")
		results_list = summary_results.detailed_results("jenkins-repose-pt-static-adhoc-155")
		assert_equal(results_list.length,2)
	end

	def test_detailed_results_repose_list
		summary_results = Results::PastSummaryResults.new("unit_test","adhoc")
		assert_not_nil(summary_results, "Summary results construction failed.")
		results_list = summary_results.detailed_results("jenkins-repose-pt-static-adhoc-155")
		assert_equal(results_list[0].length,601)
		assert_equal(results_list[0][0].date, 0)
		assert_equal(results_list[0][0].throughput, "2.0")
		assert_equal(results_list[0][0].avg, "499")
		assert_equal(results_list[0][0].errors, "0")
	end

	def test_detailed_results_origin_list
		summary_results = Results::PastSummaryResults.new("unit_test","adhoc")
		assert_not_nil(summary_results, "Summary results construction failed.")
		results_list = summary_results.detailed_results("jenkins-repose-pt-static-adhoc-155")
		assert_equal(results_list[1].length,601)
		assert_equal(results_list[1][0].date, 0)
		assert_equal(results_list[1][0].throughput, "4.0")
		assert_equal(results_list[1][0].avg, "599")
		assert_equal(results_list[1][0].errors, "0")
	end

	def test_detailed_results_file_location_not_exists
		summary_results = Results::PastSummaryResults.new("unit_test_repose_only","adhoc")
		assert_not_nil(summary_results, "Summary results construction failed.")
		assert_raise(RuntimeError) do
  			summary_results.detailed_results("not_found")
		end
	end

	def test_detailed_results_with_repose_only
		summary_results = Results::PastSummaryResults.new("unit_test_repose_only","adhoc")
		assert_not_nil(summary_results, "Summary results construction failed.")
		assert_raise(RuntimeError) do
  			summary_results.detailed_results("jenkins-repose-pt-static-adhoc-155")
		end
	end

	def test_overhead_test_results
		summary_results = Results::PastSummaryResults.new("unit_test","adhoc")
		assert_not_nil(summary_results, "Summary results construction failed.")
		assert_equal(2, summary_results.test_list.length)
		results_list = summary_results.overhead_test_results
		assert_equal(results_list.length, 1)
		assert_equal("1377793196000",results_list[0].date)
		assert_equal(0.0, results_list[0].avg)
		assert_equal("test with connection pool against Kushala's branch. via repose", results_list[0].tag)
		assert_nil(results_list[0].length)
		assert_equal(0.0, results_list[0].throughput)
		assert_equal(0.0, results_list[0].errors)
		assert_equal("jenkins-repose-pt-static-adhoc-155", results_list[0].id)
	end

	def test_overhead_test_results_empty_test_list
		summary_results = Results::PastSummaryResults.new("unit_test_dne","adhoc")
		assert_not_nil(summary_results, "Summary results construction failed.")
		results_list = summary_results.overhead_test_results
		assert_equal(results_list.length, 0)
	end

	def test_overhead_test_results_repose_only
		summary_results = Results::PastSummaryResults.new("unit_test_repose_only","adhoc")
		assert_not_nil(summary_results, "Summary results construction failed.")
		assert_equal(1, summary_results.test_list.length)
		results_list = summary_results.overhead_test_results
		assert_equal(1,results_list.length)
	end

	def test_compared_test_results
		summary_results = Results::PastSummaryResults.new("unit_test","adhoc")
		assert_not_nil(summary_results, "Summary results construction failed.")
		assert_equal(2, summary_results.test_list.length)
		results_list = summary_results.compared_test_results(['jenkins-repose-pt-static-adhoc-155'])
		assert_equal(1,results_list.length)
		assert(results_list.has_key?("jenkins-repose-pt-static-adhoc-155"))
		assert_equal(2, results_list["jenkins-repose-pt-static-adhoc-155"].length)
	end

	def test_compared_test_results_empty_list
		summary_results = Results::PastSummaryResults.new("unit_test","adhoc")
		assert_not_nil(summary_results, "Summary results construction failed.")
		assert_equal(2, summary_results.test_list.length)
		results_list = summary_results.compared_test_results([])
		assert_equal(0,results_list.length)
	end

	def test_compared_test_results_nil
		summary_results = Results::PastSummaryResults.new("unit_test","adhoc")
		assert_not_nil(summary_results, "Summary results construction failed.")
		assert_equal(2, summary_results.test_list.length)
		results_list = summary_results.compared_test_results(nil)
		assert_equal(0,results_list.length)
	end

	def test_compared_test_results_empty_test_list
		summary_results = Results::PastSummaryResults.new("unit_test_dne","adhoc")
		assert_not_nil(summary_results, "Summary results construction failed.")
		assert_equal(0, summary_results.test_list.length)
		results_list = summary_results.compared_test_results(['jenkins-repose-pt-static-adhoc-155'])
		assert_equal(0,results_list.length)
	end

	def test_compared_test_results_list_does_not_exist
		summary_results = Results::PastSummaryResults.new("unit_test","adhoc")
		assert_not_nil(summary_results, "Summary results construction failed.")
		assert_equal(2, summary_results.test_list.length)
		results_list = summary_results.compared_test_results(['dne','dne2','dne3'])
		assert_equal(0,results_list.length)
	end

	def test_compared_test_results_multiple_match
		summary_results = Results::PastSummaryResults.new("unit_test","adhoc")
		assert_not_nil(summary_results, "Summary results construction failed.")
		assert_equal(2, summary_results.test_list.length)
		results_list = summary_results.compared_test_results(['jenkins-repose-pt-static-adhoc-155','jenkins-repose-pt-static-adhoc-155'])
		assert_equal(1,results_list.length)
		assert(results_list.has_key?("jenkins-repose-pt-static-adhoc-155"))
		assert_equal(2, results_list["jenkins-repose-pt-static-adhoc-155"].length)
	end


end