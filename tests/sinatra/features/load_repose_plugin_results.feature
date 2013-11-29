Feature: Load Repose Plugin Page
	In order to load repose plugin data on test stop
	As a performance test user
	I want to save the jmx results

	Scenario: Stop atom_hopper main load test with jmeter for 60 minutes with Repose jmx data stored
		Given Test is started for "repose" "main" "load"
		When I post to '/repose/applications/main/load_test/stop' with existing guid:
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
		        "id":"repose_jmx_plugin",
		        "servers":[
  			      {
				    "server":"localhost",
				    "user":"dimi5963",
				    "path":"/Users/dimi5963/projects/hERmes_viewer/hERmes_viewer/files/apps/passthrough/results/load/tmp_20131030T163520/jmxdata.out_162.209.99.50"
				  },		            
  				  {
				    "server":"localhost",
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
		And the "results" json entry for "data" hash key in redis should exist
		And the "repose_jmx_plugin|ALL|jmxdata.out_162.209.99.50" json entry for "data" hash key in redis should exist
		And the "repose_jmx_plugin|ALL|jmxdata.out_162.209.103.227" json entry for "data" hash key in redis should exist
		And the "data" directory should contain "summary.log" file
		And the "data/repose_jmx_plugin" directory should contain "jmxdata.out_162.209.99.50" file
		And the "data/repose_jmx_plugin" directory should contain "jmxdata.out_162.209.103.227" file
		And the "request" json entry for "meta" hash key in redis should exist
		And the "response" json entry for "meta" hash key in redis should exist
		And the "script" json entry for "meta" hash key in redis should exist
		And the "meta" directory should contain "test.jmx" file
		And the "test" json entry for "meta" hash key in redis should exist
		And the "configs" list key in redis should exist and contain "57" entries

	Scenario: Stop atom_hopper main load test with jmeter for 60 minutes with Invalid id
		Given Test is started for "repose" "main" "load"
		When I post to '/repose/applications/main/load_test/stop' with existing guid:
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
		        "id":"invalid",
		        "servers":[
  		          {
				    "server":"localhost",
				    "user":"dimi5963",
				    "path":"/Users/dimi5963/projects/hERmes_viewer/hERmes_viewer/files/apps/passthrough/results/load/tmp_20131030T163520/jmxdata.out_162.209.99.50"
				  },		            
  				  {
				    "server":"localhost",
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
		And "with_errors" list has "repose_jmx_plugin" record, which should equal to "repose_jmx_plugin id not found"
		And the "results" json entry for "data" hash key in redis should exist
		And the "repose_jmx_plugin|ALL|162.209.99.50" json entry for "data" hash key in redis should not exist
		And the "repose_jmx_plugin|ALL|162.209.103.227" json entry for "data" hash key in redis should not exist
		And the "data" directory should contain "summary.log" file
		And the "data" directory should not contain "jmxdata.out_162.209.99.50" file
		And the "data" directory should not contain "jmxdata.out_162.209.103.227" file
		And the "request" json entry for "meta" hash key in redis should exist
		And the "response" json entry for "meta" hash key in redis should exist
		And the "script" json entry for "meta" hash key in redis should exist
		And the "meta" directory should contain "test.jmx" file
		And the "test" json entry for "meta" hash key in redis should exist
		And the "configs" list key in redis should exist and contain "57" entries

	Scenario: Stop atom_hopper main load test with jmeter for 60 minutes with invalid server
		Given Test is started for "repose" "main" "load"
		When I post to '/repose/applications/main/load_test/stop' with existing guid:
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
	            "id":"repose_jmx_plugin",
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
		And "with_errors" list has "repose_jmx_plugin" record, which should equal to "getaddrinfo: nodename nor servname provided, or not known"
		And the "results" json entry for "data" hash key in redis should exist
		And the "repose_jmx_plugin|ALL|162.209.99.50" json entry for "data" hash key in redis should not exist
		And the "repose_jmx_plugin|ALL|162.209.103.227" json entry for "data" hash key in redis should not exist
		And the "data" directory should contain "summary.log" file
		And the "data" directory should not contain "jmxdata.out_162.209.99.50" file
		And the "data" directory should not contain "jmxdata.out_162.209.103.227" file
		And the "request" json entry for "meta" hash key in redis should exist
		And the "response" json entry for "meta" hash key in redis should exist
		And the "script" json entry for "meta" hash key in redis should exist
		And the "meta" directory should contain "test.jmx" file
		And the "test" json entry for "meta" hash key in redis should exist
		And the "configs" list key in redis should exist and contain "57" entries