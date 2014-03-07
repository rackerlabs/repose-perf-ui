Feature: Load New Relic Plugin Page
	In order to load newrelic plugin data on test stop
	As a performance test user
	I want to save the jmx results

	Scenario: Stop newrelic_singular_app main load test with jmeter for 60 minutes with New Relic jmx data stored
		Given Test is started for "newrelic_singular_app" "main" "load"
		When I post to '/newrelic_singular_app/applications/main/load_test/stop' with existing guid:
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
		        "id":"newrelic_rest_plugin",
		        "fields":[
  			      {
				    "metric":[
				      "Controller/Sinatra/MyApp/GET api/user/([^/?#]+)/equipments_by_location/([^/?#]+)",
				      "Controller/Sinatra/MyApp/GET api/user/([^/?#]+)/exercises"
				    ],
				    "field": "average_response_time",
			        "api-key":"6ca19d43621ccdf961a4298102d559a88ad8f9896dff58b",
			        "account":396937,
			        "agent":3341593
				  },		            
  			      {
				    "metric":[
				      "Apdex",
				      "Apdex/Sinatra/MyApp/GET api/user/([^/?#]+)/workout_locations"
				    ],
				    "field": "threshold",
			        "api-key":"6ca19d43621ccdf961a4298102d559a88ad8f9896dff58b",
			        "account":396937,
			        "agent":3341593
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
		And the "newrelic_rest_plugin|time_series|newrelic.out_average_response_time" json entry for "data" hash key in redis should exist
		And the "newrelic_rest_plugin|time_series|newrelic.out_threshold" json entry for "data" hash key in redis should exist
		And the "data" directory should contain "summary.log" result file
		And the "data/newrelic_rest_plugin" directory should contain "newrelic.out_average_response_time" result file
		And the "data/newrelic_rest_plugin" directory should contain "newrelic.out_threshold" result file
		And the "request" json entry for "meta" hash key in redis should exist
		And the "response" json entry for "meta" hash key in redis should exist
		And the "script" json entry for "meta" hash key in redis should exist
		And the "meta" directory should contain "test.jmx" result file
		And the "test" json entry for "meta" hash key in redis should exist
		And the "configs" list key in redis should exist and contain "4" entries

	Scenario: Stop newrelic_singular_app main load test with jmeter for 60 minutes with Invalid id
		Given Test is started for "newrelic_singular_app" "main" "load"
		When I post to '/newrelic_singular_app/applications/main/load_test/stop' with existing guid:
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
		        "id":"invalid_id",
		        "fields":[
  			      {
				    "metric":[
				      "Controller/Sinatra/MyApp/GET api/user/([^/?#]+)/equipments_by_location/([^/?#]+)",
				      "Controller/Sinatra/MyApp/GET api/user/([^/?#]+)/exercises"
				    ],
				    "field": "average_response_time",
			        "api-key":"6ca19d43621ccdf961a4298102d559a88ad8f9896dff58b",
			        "account":396937,
			        "agent":3341593
				  },		            
  			      {
				    "metric":[
				      "Apdex",
				      "Apdex/Sinatra/MyApp/GET api/user/([^/?#]+)/workout_locations"
				    ],
				    "field": "threshold",
			        "api-key":"6ca19d43621ccdf961a4298102d559a88ad8f9896dff58b",
			        "account":396937,
			        "agent":3341593
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
		And the "newrelic_rest_plugin|time_series|newrelic.out_average_response_time" json entry for "data" hash key in redis should not exist
		And the "newrelic_rest_plugin|time_series|newrelic.out_threshold" json entry for "data" hash key in redis should not exist
		And the "data" directory should contain "summary.log" result file
		And the "data/newrelic_rest_plugin" directory should not contain "newrelic.out_average_response_time" result file
		And the "data/newrelic_rest_plugin" directory should not contain "newrelic.out_threshold" result file
		And the "request" json entry for "meta" hash key in redis should exist
		And the "response" json entry for "meta" hash key in redis should exist
		And the "script" json entry for "meta" hash key in redis should exist
		And the "meta" directory should contain "test.jmx" result file
		And the "test" json entry for "meta" hash key in redis should exist
		And the "configs" list key in redis should exist and contain "4" entries

	Scenario: Stop newrelic_singular_app main load test with jmeter for 60 minutes with invalid field
		Given Test is started for "newrelic_singular_app" "main" "load"
		When I post to '/newrelic_singular_app/applications/main/load_test/stop' with existing guid:
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
		        "id":"newrelic_rest_plugin",
		        "fields":[
  			      {
				    "metric":[
				      "Controller/Sinatra/MyApp/GET api/user/([^/?#]+)/equipments_by_location/([^/?#]+)",
				      "Controller/Sinatra/MyApp/GET api/user/([^/?#]+)/exercises"
				    ],
				    "field": "invalid field",
			        "api-key":"6ca19d43621ccdf961a4298102d559a88ad8f9896dff58b",
			        "account":396937,
			        "agent":3341593
				  },		            
  			      {
				    "metric":[
				      "Apdex",
				      "Apdex/Sinatra/MyApp/GET api/user/([^/?#]+)/workout_locations"
				    ],
				    "field": "invalid field",
			        "api-key":"6ca19d43621ccdf961a4298102d559a88ad8f9896dff58b",
			        "account":396937,
			        "agent":3341593
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
		And "with_errors" list has "newrelic_rest_plugin" record, which should contain "bad URI(is not URI?): https://api.newrelic.com/api/v1/accounts/396937/agents/3341593/data.json?metrics[]=Controller%2FSinatra%2FMyApp%2FGET+api%2Fuser%2F%28%5B%5E%2F%3F%23%5D%2B%29%2Fequipments_by_location%2F%28%5B%5E%2F%3F%23%5D%2B%29&metrics[]=Controller%2FSinatra%2FMyApp%2FGET+api%2Fuser%2F%28%5B%5E%2F%3F%23%5D%2B%29%2Fexercises&begin="
		And the "newrelic_rest_plugin|time_series|newrelic.out_average_response_time" json entry for "data" hash key in redis should not exist
		And the "newrelic_rest_plugin|time_series|newrelic.out_threshold" json entry for "data" hash key in redis should not exist
		And the "data" directory should contain "summary.log" result file
		And the "data/newrelic_rest_plugin" directory should not contain "newrelic.out_average_response_time" result file
		And the "data/newrelic_rest_plugin" directory should not contain "newrelic.out_threshold" result file
		And the "request" json entry for "meta" hash key in redis should exist
		And the "response" json entry for "meta" hash key in redis should exist
		And the "script" json entry for "meta" hash key in redis should exist
		And the "meta" directory should contain "test.jmx" result file
		And the "test" json entry for "meta" hash key in redis should exist
		And the "configs" list key in redis should exist and contain "4" entries

	Scenario: Stop newrelic_singular_app main load test with jmeter for 60 minutes with invalid api key
		Given Test is started for "newrelic_singular_app" "main" "load"
		When I post to '/newrelic_singular_app/applications/main/load_test/stop' with existing guid:
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
		        "id":"newrelic_rest_plugin",
		        "fields":[
  			      {
				    "metric":[
				      "Controller/Sinatra/MyApp/GET api/user/([^/?#]+)/equipments_by_location/([^/?#]+)",
				      "Controller/Sinatra/MyApp/GET api/user/([^/?#]+)/exercises"
				    ],
				    "field": "average_response_time",
			        "api-key":"invalid",
			        "account":396937,
			        "agent":3341593
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
		And "with_errors" list has "newrelic_rest_plugin" record, which should equal to "403 Forbidden"
		And the "newrelic_rest_plugin|time_series|newrelic.out_average_response_time" json entry for "data" hash key in redis should not exist
		And the "data" directory should contain "summary.log" result file
		And the "data/newrelic_rest_plugin" directory should not contain "newrelic.out_average_response_time" result file
		And the "request" json entry for "meta" hash key in redis should exist
		And the "response" json entry for "meta" hash key in redis should exist
		And the "script" json entry for "meta" hash key in redis should exist
		And the "meta" directory should contain "test.jmx" result file
		And the "test" json entry for "meta" hash key in redis should exist
		And the "configs" list key in redis should exist and contain "4" entries		

	Scenario: Stop newrelic_singular_app main load test with jmeter for 60 minutes with invalid account
		Given Test is started for "newrelic_singular_app" "main" "load"
		When I post to '/newrelic_singular_app/applications/main/load_test/stop' with existing guid:
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
		        "id":"newrelic_rest_plugin",
		        "fields":[
  			      {
				    "metric":[
				      "Controller/Sinatra/MyApp/GET api/user/([^/?#]+)/equipments_by_location/([^/?#]+)",
				      "Controller/Sinatra/MyApp/GET api/user/([^/?#]+)/exercises"
				    ],
				    "field": "average_response_time",
			        "api-key":"6ca19d43621ccdf961a4298102d559a88ad8f9896dff58b",
			        "account":"invalid",
			        "agent":3341593
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
		And "with_errors" list has "newrelic_rest_plugin" record, which should equal to "404 Resource Not Found"
		And the "newrelic_rest_plugin|time_series|newrelic.out_average_response_time" json entry for "data" hash key in redis should not exist
		And the "data" directory should contain "summary.log" result file
		And the "data/newrelic_rest_plugin" directory should not contain "newrelic.out_average_response_time" result file
		And the "request" json entry for "meta" hash key in redis should exist
		And the "response" json entry for "meta" hash key in redis should exist
		And the "script" json entry for "meta" hash key in redis should exist
		And the "meta" directory should contain "test.jmx" result file
		And the "test" json entry for "meta" hash key in redis should exist
		And the "configs" list key in redis should exist and contain "4" entries				

	Scenario: Stop newrelic_singular_app main load test with jmeter for 60 minutes with invalid agent
		Given Test is started for "newrelic_singular_app" "main" "load"
		When I post to '/newrelic_singular_app/applications/main/load_test/stop' with existing guid:
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
		        "id":"newrelic_rest_plugin",
		        "fields":[
  			      {
				    "metric":[
				      "Controller/Sinatra/MyApp/GET api/user/([^/?#]+)/equipments_by_location/([^/?#]+)",
				      "Controller/Sinatra/MyApp/GET api/user/([^/?#]+)/exercises"
				    ],
				    "field": "average_response_time",
			        "api-key":"6ca19d43621ccdf961a4298102d559a88ad8f9896dff58b",
			        "account":396937,
			        "agent":"invalid"
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
		And "with_errors" list has "newrelic_rest_plugin" record, which should equal to "404 Resource Not Found"
		And the "newrelic_rest_plugin|time_series|newrelic.out_average_response_time" json entry for "data" hash key in redis should not exist
		And the "data" directory should contain "summary.log" result file
		And the "data/newrelic_rest_plugin" directory should not contain "newrelic.out_average_response_time" result file
		And the "request" json entry for "meta" hash key in redis should exist
		And the "response" json entry for "meta" hash key in redis should exist
		And the "script" json entry for "meta" hash key in redis should exist
		And the "meta" directory should contain "test.jmx" result file
		And the "test" json entry for "meta" hash key in redis should exist
		And the "configs" list key in redis should exist and contain "4" entries						