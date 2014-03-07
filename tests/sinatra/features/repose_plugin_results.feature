Feature: Repose Plugin Page
	In order to view repose_singular_app plugin data
	As a performance test user
	I want to view the jmx results

	Scenario: Load repose_comparison_app main load test for key-one with filters jmx metrics
		When I navigate to '/repose_comparison_app/results/main/load_test/id/key-one+key-four/plugin/ReposeJmxPlugin/filters'
		Then the page response status code should be "200"
		And the page should contain "instance"
		And the page should contain "key-four"
		And the page should not contain "key-one"
		And the page should contain "http-logging:Mean"
		And the page should contain "key-four - filters - jmxdata.out_162.209.124.167"
		And the page should contain "2.2863381843067287"
		And the page should contain "Detailed Test Results for jmxdata.out_162.209.124.167"
		And the page should contain "2013-11-14T22:54:55+00:00"

	Scenario: Load repose_comparison_app main load test for key-one and key-four with gc jmx metrics
		When I navigate to '/repose_comparison_app/results/main/load_test/id/key-one+key-four/plugin/ReposeJmxPlugin/gc'
		Then the page response status code should be "200"
		And the page should contain "instance"
		And the page should contain "key-four"
		And the page should not contain "key-one"
		And the page should contain "PSMarkSweep.CollectionTime"
		And the page should contain "key-four - gc - jmxdata.out_162.209.124.167"
		And the page should contain "79.25"
		And the page should contain "Detailed Test Results for jmxdata.out_162.209.124.167"
		And the page should contain "2013-11-14T22:53:56+00:00"

	Scenario: Load repose_comparison_app main load test for key-one and key-four with jvm_memory jmx metrics
		When I navigate to '/repose_comparison_app/results/main/load_test/id/key-one+key-four/plugin/ReposeJmxPlugin/jvm_memory'
		Then the page response status code should be "200"
		And the page should contain "instance"
		And the page should contain "key-four"
		And the page should not contain "key-one"
		And the page should contain "HeapMemoryUsage.committed"
		And the page should contain "key-four - jvm_memory - jmxdata.out_162.209.124.167"
		And the page should contain "386301952.0"
		And the page should contain "Detailed Test Results for jmxdata.out_162.209.124.167"
		And the page should contain "2013-11-14T22:53:56+00:00"

	Scenario: Load repose_comparison_app main load test for key-one and key-four with logs jmx metrics
		When I navigate to '/repose_comparison_app/results/main/load_test/id/key-one+key-four/plugin/ReposeJmxPlugin/logs'
		Then the page response status code should be "404"
		And the error page should match the "no metric data found for repose_comparison_app/main/load_test/key-one+key-four/ReposeJmxPlugin/logs"

	Scenario: Load repose_comparison_app main load test for key-one  and key-four with jvm_threads jmx metrics
		When I navigate to '/repose_comparison_app/results/main/load_test/id/key-one+key-four/plugin/ReposeJmxPlugin/jvm_threads'
		Then the page response status code should be "200"
		And the page should contain "instance"
		And the page should contain "key-four"
		And the page should not contain "key-one"
		And the page should contain "PeakThreadCount"
		And the page should contain "key-four - jvm_threads - jmxdata.out_162.209.124.167"
		And the page should contain "41.75"
		And the page should contain "Detailed Test Results for jmxdata.out_162.209.124.167"
		And the page should contain "2013-11-14T22:53:56+00:00"

	Scenario: Load repose_comparison_app main load test for key-one with unknown jmx metrics
		When I navigate to '/repose_comparison_app/results/main/load_test/id/key-one+key-four/plugin/ReposeJmxPlugin/unknown'
		Then the page response status code should be "404"
		And the error page should match the "no metric data found for repose_comparison_app/main/load_test/key-one+key-four/ReposeJmxPlugin/unknown"

	Scenario: Load repose_comparison_app main load test for none with jvm_threads jmx metrics
		When I navigate to '/repose_comparison_app/results/main/load_test/id/none/plugin/ReposeJmxPlugin/jvm_threads'
		Then the page response status code should be "200"
		And the page should not contain "instance"
		And the page should not contain "key-four"
		And the page should not contain "key-one"
		And the page should contain "No data is present"

	Scenario: Load repose_comparison_app main none test for key-one and key-four with jvm_threads jmx metrics
		When I navigate to '/repose_comparison_app/results/main/none/id/key-one+key-four/plugin/ReposeJmxPlugin/jvm_threads'
		Then the page response status code should be "404"
		And the error page should match the "No application by name of repose_comparison_app/none found"

	Scenario: Load repose_comparison_app none load test for key-one and key-four with jvm_threads jmx metrics
		When I navigate to '/repose_comparison_app/results/none/load_test/id/key-one+key-four/plugin/ReposeJmxPlugin/jvm_threads'
		Then the page response status code should be "404"
		And the error page should match the "No sub application for none found"

	Scenario: Load repose_singular_app main load test for key-one with filters jmx metrics
		When I navigate to '/repose_singular_app/results/main/load_test/id/key-one/plugin/ReposeJmxPlugin/filters'
		Then the page response status code should be "200"
		And the page should contain "instance"
		And the page should contain "http-logging:Mean"
		And the page should contain "filters - jmxdata.out_162.209.124.167"
		And the page should contain "2.2863381843067287"
		And the page should contain "Detailed Test Results for jmxdata.out_162.209.124.167"
		And the page should contain "2013-11-14T22:54:55+00:00"

	Scenario: Load repose_singular_app main load test for key-one with gc jmx metrics
		When I navigate to '/repose_singular_app/results/main/load_test/id/key-one/plugin/ReposeJmxPlugin/gc'
		Then the page response status code should be "200"
		And the page should contain "instance"
		And the page should contain "PSMarkSweep.CollectionTime"
		And the page should contain "gc - jmxdata.out_162.209.124.167"
		And the page should contain "79.25"
		And the page should contain "Detailed Test Results for jmxdata.out_162.209.124.167"
		And the page should contain "2013-11-14T22:53:56+00:00"

	Scenario: Load repose_singular_app main load test for key-one with jvm_memory jmx metrics
		When I navigate to '/repose_singular_app/results/main/load_test/id/key-one/plugin/ReposeJmxPlugin/jvm_memory'
		Then the page response status code should be "200"
		And the page should contain "instance"
		And the page should contain "HeapMemoryUsage.committed"
		And the page should contain "jvm_memory - jmxdata.out_162.209.124.167"
		And the page should contain "386301952.0"
		And the page should contain "Detailed Test Results for jmxdata.out_162.209.124.167"
		And the page should contain "2013-11-14T22:53:56+00:00"

	Scenario: Load repose_singular_app main load test for key-one with logs jmx metrics
		When I navigate to '/repose_singular_app/results/main/load_test/id/key-one/plugin/ReposeJmxPlugin/logs'
		Then the page response status code should be "404"
		And the error page should match the "no metric data found for repose_singular_app/main/load_test/key-one/ReposeJmxPlugin/logs"

	Scenario: Load repose_singular_app main load test for key-one with jvm_threads jmx metrics
		When I navigate to '/repose_singular_app/results/main/load_test/id/key-one/plugin/ReposeJmxPlugin/jvm_threads'
		Then the page response status code should be "200"
		And the page should contain "instance"
		And the page should contain "PeakThreadCount"
		And the page should contain "jvm_threads - jmxdata.out_162.209.124.167"
		And the page should contain "41.75"
		And the page should contain "Detailed Test Results for jmxdata.out_162.209.124.167"
		And the page should contain "2013-11-14T22:53:56+00:00"

	Scenario: Load repose_singular_app main load test for key-one with unknown jmx metrics
		When I navigate to '/repose_singular_app/results/main/load_test/id/key-one/plugin/ReposeJmxPlugin/unknown'
		Then the page response status code should be "404"
		And the error page should match the "no metric data found for repose_singular_app/main/load_test/key-one/ReposeJmxPlugin/unknown"

	Scenario: Load repose_singular_app main load test for none with jvm_threads jmx metrics
		When I navigate to '/repose_singular_app/results/main/load_test/id/none/plugin/ReposeJmxPlugin/jvm_threads'
		Then the page response status code should be "200"
		And the page should contain "instance"
		And the page should contain "PeakThreadCount"
		And the page should not contain "jvm_threads - jmxdata.out_162.209.124.167"
		And the page should not contain "Detailed Test Results for jmxdata.out_162.209.124.167"
		And the page should not contain "2013-11-14T22:53:56+00:00"

	Scenario: Load repose_singular_app main none test for key-one with jvm_threads jmx metrics
		When I navigate to '/repose_singular_app/results/main/none/id/key-one/plugin/ReposeJmxPlugin/jvm_threads'
		Then the page response status code should be "404"
		And the error page should match the "No application by name of repose_singular_app/none found"

	Scenario: Load repose_singular_app none load test for key-one with jvm_threads jmx metrics
		When I navigate to '/repose_singular_app/results/none/load_test/id/key-one/plugin/ReposeJmxPlugin/jvm_threads'
		Then the page response status code should be "404"
		And the error page should match the "No sub application for none found"

	Scenario: Load none main load test for key-one with jvm_threads jmx metrics
		When I navigate to '/none/results/main/load_test/id/key-one/plugin/ReposeJmxPlugin/jvm_threads'
		Then the page response status code should be "404"
		And the error page should match the "No application by name of none/load_test found"
