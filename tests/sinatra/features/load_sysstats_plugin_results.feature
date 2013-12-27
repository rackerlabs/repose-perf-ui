Feature: Load Repose Plugin Page
	In order to load repose plugin data on test stop
	As a performance test user
	I want to save the jmx results

	Scenario: Stop sysstats main load test with jmeter for 60 minutes with Sysstats data stored
		Given Test is started for "sysstats" "main" "load"
		When I post to '/sysstats/applications/main/load_test/stop' with existing guid:
		"""
		  {
		    "servers":
  	        {
		      "config":
  	          {
	            "server":"localhost",
	            "user":"dimi5963",
	            "path":"/Users/dimi5963/projects/hERmes_viewer/hERmes_viewer/tests/files/configs/"
	          },
		      "results":
		      {
	            "server":"localhost",
	            "user":"dimi5963",
		        "path":"/Users/dimi5963/projects/hERmes_viewer/hERmes_viewer/tests/files/data/summary.log"
		      }
		    },
		    "plugins":
		    [
		      {
		        "id":"sysstats_plugin",
		        "servers":[
  			      {
		            "server":"10.23.246.101",
		            "user":"root",
		            "path":"/root/repose/dist/files/apps/ah/results/adhoc/tmp_20131114T183805/sysstats.log_162.209.124.158"
				  },		            
  				  {
		            "server":"10.23.246.101",
		            "user":"root",
		            "path":"/root/repose/dist/files/apps/ah/results/adhoc/tmp_20131114T183805/sysstats.log_162.209.124.167"
				  }		            
		        ]
		      }
		    ]
		  }
		"""
		Then the response should be "200"
		And response should be a json
		And "result" json record should equal to "OK"
		And the "results" json entry for "data" hash key in redis should exist
		And the "sysstats_plugin|time_series|sysstats_cpu.out_10.23.246.101" json entry for "data" hash key in redis should exist
		And the "sysstats_plugin|time_series|sysstats_kernel.out_10.23.246.101" json entry for "data" hash key in redis should exist
		And the "sysstats_plugin|time_series|sysstats_device_disk.out_10.23.246.101" json entry for "data" hash key in redis should exist
		And the "sysstats_plugin|time_series|sysstats_device_failure.out_10.23.246.101" json entry for "data" hash key in redis should exist
		And the "sysstats_plugin|time_series|sysstats_device_network.out_10.23.246.101" json entry for "data" hash key in redis should exist
		And the "sysstats_plugin|time_series|sysstats_ip_failure_network.out_10.23.246.101" json entry for "data" hash key in redis should exist
		And the "sysstats_plugin|time_series|sysstats_ip_network.out_10.23.246.101" json entry for "data" hash key in redis should exist
		And the "sysstats_plugin|time_series|sysstats_tcp_failure_network.out_10.23.246.101" json entry for "data" hash key in redis should exist
		And the "sysstats_plugin|time_series|sysstats_tcp_network.out_10.23.246.101" json entry for "data" hash key in redis should exist
		And the "sysstats_plugin|time_series|sysstats_memory_page.out_10.23.246.101" json entry for "data" hash key in redis should exist
		And the "sysstats_plugin|time_series|sysstats_memory_swap.out_10.23.246.101" json entry for "data" hash key in redis should exist
		And the "sysstats_plugin|time_series|sysstats_memory_utilization.out_10.23.246.101" json entry for "data" hash key in redis should exist
		And the "data" directory should contain "summary.log" file
		And the "data/sysstats_plugin" directory should contain "sysstats_cpu.out_10.23.246.101" file
		And the "data/sysstats_plugin" directory should contain "sysstats_kernel.out_10.23.246.101" file
		And the "data/sysstats_plugin" directory should contain "sysstats_device_disk.out_10.23.246.101" file
		And the "data/sysstats_plugin" directory should contain "sysstats_device_failure.out_10.23.246.101" file
		And the "data/sysstats_plugin" directory should contain "sysstats_ip_failure_network.out_10.23.246.101" file
		And the "data/sysstats_plugin" directory should contain "sysstats_ip_network.out_10.23.246.101" file
		And the "data/sysstats_plugin" directory should contain "sysstats_tcp_failure_network.out_10.23.246.101" file
		And the "data/sysstats_plugin" directory should contain "sysstats_tcp_network.out_10.23.246.101" file
		And the "data/sysstats_plugin" directory should contain "sysstats_memory_page.out_10.23.246.101" file
		And the "data/sysstats_plugin" directory should contain "sysstats_memory_swap.out_10.23.246.101" file
		And the "data/sysstats_plugin" directory should contain "sysstats_memory_utilization.out_10.23.246.101" file
		And the "request" json entry for "meta" hash key in redis should exist
		And the "response" json entry for "meta" hash key in redis should exist
		And the "script" json entry for "meta" hash key in redis should exist
		And the "meta" directory should contain "test.jmx" file
		And the "test" json entry for "meta" hash key in redis should exist
		And the "configs" list key in redis should exist and contain "57" entries

	Scenario: Stop sysstats main load test with jmeter for 60 minutes with invalid server
		Given Test is started for "sysstats" "main" "load"
		When I post to '/sysstats/applications/main/load_test/stop' with existing guid:
		"""
		  {
		    "servers":
  	        {
		      "config":
  	          {
	            "server":"localhost",
	            "user":"dimi5963",
	            "path":"/Users/dimi5963/projects/hERmes_viewer/hERmes_viewer/tests/files/configs/"
	          },
		      "results":
		      {
	            "server":"localhost",
	            "user":"dimi5963",
		        "path":"/Users/dimi5963/projects/hERmes_viewer/hERmes_viewer/tests/files/data/summary.log"
		      }
		    },
	        "plugins":
	        [
	          {
	            "id":"sysstats_plugin",
	            "servers":[
			      {
			        "server":"invalid",
			        "user":"dimi5963",
			        "path":"/Users/dimi5963/projects/hERmes_viewer/hERmes_viewer/files/apps/passthrough/results/load/tmp_20131030T163520/jmxdata.out_162.209.99.50"
			      },		            
			      {
			        "server":"invalid",
			        "user":"dimi5963",
			        "path":"/Users/dimi5963/projects/hERmes_viewer/hERmes_viewer/files/apps/passthrough/results/load/tmp_20131030T163520/jmxdata.out_162.209.103.227"
		          }		            
	            ]
	          }
  	        ]
		  }
		"""
		Then the response should be "200"
		And response should be a json
		And "result" json record should equal to "OK"
		And "with_errors" list has "sysstats_plugin" record, which should equal to "getaddrinfo: nodename nor servname provided, or not known"
		And the "results" json entry for "data" hash key in redis should exist
		And the "sysstats_plugin|time_series|sysstats_cpu.out_10.23.246.101" json entry for "data" hash key in redis should not exist
		And the "sysstats_plugin|time_series|sysstats_kernel.out_10.23.246.101" json entry for "data" hash key in redis should not exist
		And the "sysstats_plugin|time_series|sysstats_device_disk.out_10.23.246.101" json entry for "data" hash key in redis should not exist
		And the "sysstats_plugin|time_series|sysstats_device_failure.out_10.23.246.101" json entry for "data" hash key in redis should not exist
		And the "sysstats_plugin|time_series|sysstats_device_network.out_10.23.246.101" json entry for "data" hash key in redis should not exist
		And the "sysstats_plugin|time_series|sysstats_ip_failure_network.out_10.23.246.101" json entry for "data" hash key in redis should not exist
		And the "sysstats_plugin|time_series|sysstats_ip_network.out_10.23.246.101" json entry for "data" hash key in redis should not exist
		And the "sysstats_plugin|time_series|sysstats_tcp_failure_network.out_10.23.246.101" json entry for "data" hash key in redis should not exist
		And the "sysstats_plugin|time_series|sysstats_tcp_network.out_10.23.246.101" json entry for "data" hash key in redis should not exist
		And the "sysstats_plugin|time_series|sysstats_memory_page.out_10.23.246.101" json entry for "data" hash key in redis should not exist
		And the "sysstats_plugin|time_series|sysstats_memory_swap.out_10.23.246.101" json entry for "data" hash key in redis should not exist
		And the "sysstats_plugin|time_series|sysstats_memory_utilization.out_10.23.246.101" json entry for "data" hash key in redis should not exist
		And the "data" directory should contain "summary.log" file
		And the "data/sysstats_plugin" directory should not contain "sysstats_cpu.out_10.23.246.101" file
		And the "data/sysstats_plugin" directory should not contain "sysstats_kernel.out_10.23.246.101" file
		And the "data/sysstats_plugin" directory should not contain "sysstats_device_disk.out_10.23.246.101" file
		And the "data/sysstats_plugin" directory should not contain "sysstats_device_failure.out_10.23.246.101" file
		And the "data/sysstats_plugin" directory should not contain "sysstats_ip_failure_network.out_10.23.246.101" file
		And the "data/sysstats_plugin" directory should not contain "sysstats_ip_network.out_10.23.246.101" file
		And the "data/sysstats_plugin" directory should not contain "sysstats_tcp_failure_network.out_10.23.246.101" file
		And the "data/sysstats_plugin" directory should not contain "sysstats_tcp_network.out_10.23.246.101" file
		And the "data/sysstats_plugin" directory should not contain "sysstats_memory_page.out_10.23.246.101" file
		And the "data/sysstats_plugin" directory should not contain "sysstats_memory_swap.out_10.23.246.101" file
		And the "data/sysstats_plugin" directory should not contain "sysstats_memory_utilization.out_10.23.246.101" file
		And the "request" json entry for "meta" hash key in redis should exist
		And the "response" json entry for "meta" hash key in redis should exist
		And the "script" json entry for "meta" hash key in redis should exist
		And the "meta" directory should contain "test.jmx" file
		And the "test" json entry for "meta" hash key in redis should exist
		And the "configs" list key in redis should exist and contain "57" entries