Feature: File Plugin Page
	In order to view file_singular_app plugin data
	As a performance test user
	I want to view the large files

	Scenario: Load file_singular_app main load test for key-three with file metrics
		When I navigate to '/file_singular_app/results/main/load_test/id/key-three/plugin/FilePlugin/file'
		Then the page response status code should be "200"
		And the page should contain "Summary Test Results for key-three - jmxdata.out_162.209.124.167"
		And the page should contain "localhost_9999.sun_management_GarbageCollectorImpl.PSMarkSweep.CollectionTime"
		And the page should contain "1384469636126"
		And the page should contain "1384469875986"
		And the page should not contain "1384469875995"
		And the page should not contain "1384469876001"
		And the page should contain "localhost_9999.com_yammer_metrics_reporting_JmxReporter$T"

	Scenario: Load file_singular_app main load test for key-three with file metrics for first page
		When I click on '/file_singular_app/results/main/load_test/id/key-three/plugin/FilePlugin/file/0/25600'
		Then the response should be "200"
		And response should be a json
		And there should be "1" "results" records in response
		And the message should contain "localhost_9999.sun_management_GarbageCollectorImpl.PSMarkSweep.CollectionTime"
		And the message should contain "1384469636126"
		And the message should contain "1384469636140"
		And the message should not contain "1384469875995"
		And the message should not contain "1384469876001"
		And the message should contain "localhost_9999.com_yammer_metrics_reporting_JmxReporter$T"

	Scenario: Load file_singular_app main load test for key-three with file metrics for last page
		When I click on '/file_singular_app/results/main/load_test/id/key-three/plugin/FilePlugin/file/25600/25600'
		Then the response should be "200"
		And response should be a json
		And there should be "1" "results" records in response
		And the message should contain "localhost_9999.sun_management_GarbageCollectorImpl.PSMarkSweep.CollectionTime"
		And the message should not contain "1384469636126"
		And the message should not contain "1384469636140"
		And the message should contain "1384469875995"
		And the message should contain "1384469876001"

	Scenario: Load file_singular_app main load test for key-three with file metrics for page 2
		When I click on '/file_singular_app/results/main/load_test/id/key-three/plugin/FilePlugin/file/25600/25600'
		Then the response should be "200"
		And response should be a json
		And there should be "1" "results" records in response
		And the message should contain "localhost_9999.sun_management_GarbageCollectorImpl.PSMarkSweep.CollectionTime"
		And the message should not contain "1384469636126"
		And the message should not contain "1384469636140"
		And the message should contain "1384469875995"
		And the message should contain "1384469876001"

	Scenario: Search file_singular_app for all occurrences of string
		When I click on '/file_singular_app/results/main/load_test/id/key-three/plugin/FilePlugin/file/find/Garbage'
		Then the response should be "200"
		And response should be a json
		And there should be "1" "results" records in response
		And the message should contain "localhost_9999.sun_management_GarbageCollectorImpl.PSMarkSweep.CollectionTime"
		And the message should not contain "localhost_9999.sun_management_MemoryPoolImpl.PSSurvivorSpace.CollectionUsage_used"
		And the message should not contain "localhost_9999.com_yammer_metrics_reporting_JmxReporter$T"

	Scenario: Search file_singular_app for all occurrences of non-existent string
		When I click on '/file_singular_app/results/main/load_test/id/key-three/plugin/FilePlugin/file/find/xyz'
		Then the response should be "200"
		And response should be a json
		And there should be "1" "results" records in response
		And the message should not contain "localhost_9999.sun_management_GarbageCollectorImpl.PSMarkSweep.CollectionTime\t0\t1384469636126"
		And the message should not contain "imer.client-auth.75thPercentile\t2.0\t1384469875995\tlocalhost_9999.sun_management_MemoryPoolImpl.PSSurvivorSpace.CollectionUsage_used\t491600\t1384469875986"
		And the message should not contain "localhost_9999.com_yammer_metrics_reporting_JmxReporter$T"

	Scenario: Load file_singular_app main load test for key-three with unknown metric
		When I navigate to '/file_singular_app/results/main/load_test/id/key-three/plugin/FilePlugin/unknown'
		Then the page response status code should be "404"
		And the error page should match the "no metric data found for file_singular_app/main/load_test/key-three/FilePlugin/unknown"

	Scenario: Load file_singular_app main load test for none with file metrics
		When I navigate to '/file_singular_app/results/main/load_test/id/none/plugin/FilePlugin/file'
		Then the page response status code should be "404"
		And the error page should match the "no metric data found for file_singular_app/main/load_test/none/FilePlugin/file"

	Scenario: Load file_singular_app main none test for key-three with file metrics
		When I navigate to '/file_singular_app/results/main/none/id/key-three/plugin/FilePlugin/file'
		Then the page response status code should be "404"
		And the error page should match the "No application by name of file_singular_app/none found"

	Scenario: Load file_singular_app none load test for key-three with file metrics
		When I navigate to '/file_singular_app/results/none/load_test/id/key-three/plugin/FilePlugin/file'
		Then the page response status code should be "404"
		And the error page should match the "No sub application for none found"

	Scenario: Load none main load test for key-three with file metrics
		When I navigate to '/none/results/main/load_test/id/key-three/plugin/FilePlugin/file'
		Then the page response status code should be "404"
		And the error page should match the "No application by name of none/load_test found"


	Scenario: Load file_comparison_app main load test for key-one and key-four with file metrics
		When I navigate to '/file_comparison_app/results/main/load_test/id/key-one+key-four/plugin/FilePlugin/file'
		Then the page response status code should be "200"
		And the page should contain "Summary Test Results for - key-one - jmxdata.out_162.209.124.167"
		And the page should contain "Summary Test Results for - key-four - jmxdata.out_162.209.124.167"
		And the page should contain "localhost_9999.sun_management_GarbageCollectorImpl.PSMarkSweep.CollectionTime"
		And the page should contain "1384469636126"
		And the page should contain "1384469875986"
		And the page should not contain "1384469875995"
		And the page should not contain "1384469876001"
		And the page should contain "localhost_9999.com_yammer_metrics_reporting_JmxReporter$T"

	Scenario: Load file_comparison_app main load test for key-one with file metrics for first page
		When I click on '/file_comparison_app/results/main/load_test/id/key-one/plugin/FilePlugin/file/0/25600'
		Then the response should be "200"
		And response should be a json
		And there should be "2" "results" records in response
		And the message should contain "localhost_9999.sun_management_GarbageCollectorImpl.PSMarkSweep.CollectionTime"
		And the message should contain "1384469636126"
		And the message should contain "1384469636140"
		And the message should not contain "1384469875995"
		And the message should not contain "1384469876001"
		And the message should contain "localhost_9999.com_yammer_metrics_reporting_JmxReporter$T"

	Scenario: Load file_comparison_app main load test for key-one with file metrics for last page
		When I click on '/file_comparison_app/results/main/load_test/id/key-one/plugin/FilePlugin/file/25600/25600'
		Then the response should be "200"
		And response should be a json
		And there should be "2" "results" records in response
		And the message should contain "localhost_9999.sun_management_GarbageCollectorImpl.PSMarkSweep.CollectionTime"
		And the message should not contain "1384469636126"
		And the message should not contain "1384469636140"
		And the message should contain "1384469875995"
		And the message should contain "1384469876001"

	Scenario: Load file_comparison_app main load test for key-one with file metrics for page 2
		When I click on '/file_comparison_app/results/main/load_test/id/key-one/plugin/FilePlugin/file/25600/25600'
		Then the response should be "200"
		And response should be a json
		And there should be "2" "results" records in response
		And the message should contain "localhost_9999.sun_management_GarbageCollectorImpl.PSMarkSweep.CollectionTime"
		And the message should not contain "1384469636126"
		And the message should not contain "1384469636140"
		And the message should contain "1384469875995"
		And the message should contain "1384469876001"

	Scenario: Search file_comparison_app for all occurrences of string
		When I click on '/file_comparison_app/results/main/load_test/id/key-one/plugin/FilePlugin/file/find/Garbage'
		Then the response should be "200"
		And response should be a json
		And there should be "2" "results" records in response
		And the message should contain "localhost_9999.sun_management_GarbageCollectorImpl.PSMarkSweep.CollectionTime"
		And the message should not contain "localhost_9999.sun_management_MemoryPoolImpl.PSSurvivorSpace.CollectionUsage_used"
		And the message should not contain "localhost_9999.com_yammer_metrics_reporting_JmxReporter$T"

	Scenario: Search file_comparison_app for all occurrences of non-existent string
		When I click on '/file_comparison_app/results/main/load_test/id/key-one/plugin/FilePlugin/file/find/xyz'
		Then the response should be "200"
		And response should be a json
		And there should be "2" "results" records in response
		And the message should not contain "localhost_9999.sun_management_GarbageCollectorImpl.PSMarkSweep.CollectionTime\t0\t1384469636126"
		And the message should not contain "imer.client-auth.75thPercentile\t2.0\t1384469875995\tlocalhost_9999.sun_management_MemoryPoolImpl.PSSurvivorSpace.CollectionUsage_used\t491600\t1384469875986"
		And the message should not contain "localhost_9999.com_yammer_metrics_reporting_JmxReporter$T"
