require './tests/Models/test_helper.rb'
require  './Models/results.rb'

class LiveSummaryResultsTest < Test::Unit::TestCase

	def test_construction_for_invalid_app
		live_summary_results = Results::LiveSummaryResults.new("unit_test_invalid","adhoc")
		assert_equal("/Users/dimi5963/projects/repose_pt/files/apps/unit_test_invalid/results/adhoc/current/summary.log",live_summary_results.summary_location)
		assert_equal([],live_summary_results.summary_results)
		assert_equal([],live_summary_results.new_summary_results)
		assert_equal([],live_summary_results.summary_result_times)
		assert_equal(0,live_summary_results.time)
		assert_equal(false,live_summary_results.test_ended)
	end

	def test_construction_for_invalid_test_type
		live_summary_results = Results::LiveSummaryResults.new("unit_test","unit_test_type")
		assert_equal("/Users/dimi5963/projects/repose_pt/files/apps/unit_test/results/unit_test_type/current/summary.log",live_summary_results.summary_location)
		assert_equal([],live_summary_results.summary_results)
		assert_equal([],live_summary_results.new_summary_results)
		assert_equal([],live_summary_results.summary_result_times)
		assert_equal(0,live_summary_results.time)
		assert_equal(false,live_summary_results.test_ended)
	end

	def test_construction_with_custom_config
		live_summary_results = Results::LiveSummaryResults.new("unit_test","adhoc","./config/config.yaml")
		assert_equal("/Users/dimi5963/projects/repose_pt/files/apps/unit_test/results/adhoc/current/summary.log",live_summary_results.summary_location)
		assert_equal([],live_summary_results.summary_results)
		assert_equal([],live_summary_results.new_summary_results)
		assert_equal([],live_summary_results.summary_result_times)
		assert_equal(0,live_summary_results.time)
		assert_equal(false,live_summary_results.test_ended)
	end

	def test_construction_with_custom_invalid_config
		live_summary_results = Results::LiveSummaryResults.new("unit_test","adhoc","this_is_random.yaml")
		assert_equal("/Users/dimi5963/projects/repose_pt/files/apps/unit_test/results/adhoc/current/summary.log",live_summary_results.summary_location)
		assert_equal([],live_summary_results.summary_results)
		assert_equal([],live_summary_results.new_summary_results)
		assert_equal([],live_summary_results.summary_result_times)
		assert_equal(0,live_summary_results.time)
		assert_equal(false,live_summary_results.test_ended)
	end

	def test_construction
		live_summary_results = Results::LiveSummaryResults.new("unit_test","adhoc")
		assert_equal("/Users/dimi5963/projects/repose_pt/files/apps/unit_test/results/adhoc/current/summary.log",live_summary_results.summary_location)
		assert_equal([],live_summary_results.summary_results)
		assert_equal([],live_summary_results.new_summary_results)
		assert_equal([],live_summary_results.summary_result_times)
		assert_equal(0,live_summary_results.time)
		assert_equal(false,live_summary_results.test_ended)
	end

	def test_convert_summary 
		live_summary_results = Results::LiveSummaryResults.new("unit_test","adhoc")
		live_summary_results.convert_summary
		assert_equal(3033, live_summary_results.time)
		assert_equal(false, live_summary_results.test_ended)
		assert_equal(1005, live_summary_results.summary_result_times.length)
		assert_equal(501, live_summary_results.summary_results.length)
	end

	def test_convert_summary_with_interval
		live_summary_results = Results::LiveSummaryResults.new("unit_test","adhoc")
		live_summary_results.convert_summary(3)
		assert_equal(3033, live_summary_results.time)
		assert_equal(false, live_summary_results.test_ended)
		assert_equal(1005, live_summary_results.summary_result_times.length)
		assert_equal(501, live_summary_results.summary_results.length)		
	end

	def test_convert_summary_file_does_not_exist
		live_summary_results = Results::LiveSummaryResults.new("unit_test_dne","adhoc")
		live_summary_results.convert_summary
		assert_equal(0, live_summary_results.time)
		assert_equal(true, live_summary_results.test_ended)
		assert_equal([], live_summary_results.summary_result_times)
		assert_equal([], live_summary_results.summary_results)
	end

	def test_convert_summary_not_ended
		live_summary_results = Results::LiveSummaryResults.new("unit_test","adhoc_summary_not_ended")
		live_summary_results.convert_summary
		assert_equal(3063, live_summary_results.time)
		assert_equal(false, live_summary_results.test_ended)
		assert_equal(1015, live_summary_results.summary_result_times.length)
		assert_equal(506, live_summary_results.summary_results.length)
	end

	def test_convert_summary_ended
		live_summary_results = Results::LiveSummaryResults.new("unit_test","adhoc_summary_ended")
		live_summary_results.convert_summary
		assert_equal(3643, live_summary_results.time)
		assert_equal(true, live_summary_results.test_ended)
		assert_equal(1207, live_summary_results.summary_result_times.length)
		assert_equal(601, live_summary_results.summary_results.length)
	end

	def test_new_summary_values
		#initialize
		live_summary_results = Results::LiveSummaryResults.new("unit_test","adhoc_summary_not_ended")
		assert_equal("/Users/dimi5963/projects/repose_pt/files/apps/unit_test/results/adhoc_summary_not_ended/current/summary.log",live_summary_results.summary_location)
		live_summary_results.convert_summary
		assert_equal(3063, live_summary_results.time)
		assert_equal(false, live_summary_results.test_ended)
		assert_equal(1015, live_summary_results.summary_result_times.length)
		assert_equal(506, live_summary_results.summary_results.length)
		#validate new_summary_values as nil
		live_summary_results.new_summary_values
		assert_equal([],live_summary_results.new_summary_values)
		#add line to file
		results = File.read(live_summary_results.summary_location)
		temp_results = results + "\nsummary +   6257 in     6s = 1037.1/s Avg:    38 Min:    33 Max:   267 Err:     0 (0.00%) Active: 40 Started: 40 Finished: 0\n"
		temp_results += "summary = 3066619 in  3000s = 1022.3/s Avg:    38 Min:    32 Max:  3058 Err:     0 (0.00%)"
		File.open(live_summary_results.summary_location, 'w') {|f| f.write(temp_results)}
		#wait 9 secs
		sleep 9
		live_summary_results.new_summary_values
		#validate new_summary_values has 1 line
		assert_equal(1,live_summary_results.new_summary_values.length)
		#valudate summary has summary + 1 line
		assert_equal(508,live_summary_results.summary_results.length)
		assert_equal(false, live_summary_results.test_ended)
		#remove line
		File.open(live_summary_results.summary_location, 'w') {|f| f.write(results)}
	end

	def test_new_summary_values_with_interval
		#initialize
		live_summary_results = Results::LiveSummaryResults.new("unit_test","adhoc_summary_not_ended")
		assert_equal("/Users/dimi5963/projects/repose_pt/files/apps/unit_test/results/adhoc_summary_not_ended/current/summary.log",live_summary_results.summary_location)
		live_summary_results.convert_summary(3)
		assert_equal(3063, live_summary_results.time)
		assert_equal(false, live_summary_results.test_ended)
		assert_equal(1015, live_summary_results.summary_result_times.length)
		assert_equal(506, live_summary_results.summary_results.length)
		#validate new_summary_values as nil
		live_summary_results.new_summary_values
		assert_equal([],live_summary_results.new_summary_values)
		#add line to file
		results = File.read(live_summary_results.summary_location)
		temp_results = results + "\nsummary +   6257 in     6s = 1037.1/s Avg:    38 Min:    33 Max:   267 Err:     0 (0.00%) Active: 40 Started: 40 Finished: 0\n"
		temp_results += "summary = 3066619 in  3000s = 1022.3/s Avg:    38 Min:    32 Max:  3058 Err:     0 (0.00%)"
		File.open(live_summary_results.summary_location, 'w') {|f| f.write(temp_results)}
		#wait 9 secs
		sleep 5
		live_summary_results.new_summary_values
		#validate new_summary_values has 1 line
		assert_equal(1,live_summary_results.new_summary_values.length)
		#valudate summary has summary + 1 line
		assert_equal(508,live_summary_results.summary_results.length)
		assert_equal(false, live_summary_results.test_ended)
		#remove line
		File.open(live_summary_results.summary_location, 'w') {|f| f.write(results)}
	end

	def test_new_summary_values_test_ended
		#initialize
		live_summary_results = Results::LiveSummaryResults.new("unit_test","adhoc_summary_ending")
		live_summary_results.convert_summary
		assert_equal(3063, live_summary_results.time)
		assert_equal(false, live_summary_results.test_ended)
		assert_equal(1015, live_summary_results.summary_result_times.length)
		assert_equal(506, live_summary_results.summary_results.length)
		#validate new_summary_values as nil
		live_summary_results.new_summary_values
		assert_equal([],live_summary_results.new_summary_values)
		#add 3 lines as ended
		results = File.read(live_summary_results.summary_location)
		temp_results = results + "\nsummary +   4856 in   5.1s =  947.5/s Avg:    41 Min:    34 Max:   378 Err:     0 (0.00%) Active: 0 Started: 40 Finished: 40\n"
		temp_results += "summary = 3435848 in  3599s =  954.6/s Avg:    41 Min:    34 Max:  3104 Err:     0 (0.00%)\n"
		temp_results += "Tidying up ...    @ Thu Aug 29 17:19:56 UTC 2013 (1377796796048)\n"
		temp_results += "... end of run\n"
		File.open(live_summary_results.summary_location, 'w') {|f| f.write(temp_results)}
		#wait 9 secs
		sleep 9
		live_summary_results.new_summary_values
		#remove line
		File.open(live_summary_results.summary_location, 'w') {|f| f.write(results)}
		assert_equal(1,live_summary_results.new_summary_values.length)
		assert_equal(508,live_summary_results.summary_results.length)
		assert_equal(true, live_summary_results.test_ended)
	end

	def test_new_summary_values_location_dne
		live_summary_results = Results::LiveSummaryResults.new("unit_test_dne","adhoc")
		live_summary_results.convert_summary
		assert_equal(0, live_summary_results.time)
		assert_equal(true, live_summary_results.test_ended)
		assert_equal([], live_summary_results.summary_result_times)
		assert_equal([], live_summary_results.summary_results)
		live_summary_results.new_summary_values
		assert_equal([],live_summary_results.new_summary_results)
		sleep 7
		assert_equal([],live_summary_results.new_summary_results)
	end

end