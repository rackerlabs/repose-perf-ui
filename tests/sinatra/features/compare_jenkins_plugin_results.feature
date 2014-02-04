Feature: Compare JenkinsRest Plugin Page
	In order to compare tests with rest plugin data
	As a performance test user
	I want to compare the rest tests

	Scenario: Compare jenkins_comparison_app (overhead) main load test key-one+key-four+key-two+key-five for status metrics
		When I post to "/jenkins_comparison_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-four+key-two+key-five", 
			"plugin_id": "JenkinsRestPlugin|||status"
		  }
		"""
		Then the response should be "200"
		And the message should contain "key-one"
		And the message should contain "key-two"
		And the message should not contain "key-three"
		And the message should contain "key-four"
		And the message should contain "key-five"
		And the message should contain "actions->causes->shortDescription"
		And the message should contain "Started by user gabe.westmaas"
		And the message should contain "actions->causes->userName"
		And the message should contain "building"
		And the message should contain "616063"
		And the message should contain "difference of -30000.0"
		And the message should contain "2014-03-07_16-23-27"
		And the message should contain "difference of 9899700000.0"
	
	Scenario: Compare jenkins_comparison_app (overhead) main load test key-one+key-four+key-two+key-five+key-three for status metrics
		When I post to "/jenkins_comparison_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-four+key-two+key-five+key-three", 
			"plugin_id": "JenkinsRestPlugin|||status"
		  }
		"""
		Then the response should be "200"
		And the message should contain "key-one"
		And the message should contain "key-two"
		And the message should contain "key-three"
		And the message should contain "key-four"
		And the message should contain "key-five"
		And the message should contain "actions->causes->shortDescription"
		And the message should contain "Started by user gabe.westmaas"
		And the message should contain "actions->causes->userName"
		And the message should contain "building"
		And the message should contain "616063"
		And the message should contain "difference of -30000.0"
		And the message should contain "2014-03-07_16-23-27"
		And the message should contain "difference of 9899700000.0"

	Scenario: Compare jenkins_comparison_app (overhead) main load test key-one+key-four+key-two+key-five+invalid-key-three for status metrics
		When I post to "/jenkins_comparison_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-four+key-two+key-five+invalid-key-three", 
			"plugin_id": "JenkinsRestPlugin|||status"
		  }
		"""
		Then the response should be "200"
		And the message should contain "key-one"
		And the message should contain "key-two"
		And the message should not contain "key-three"
		And the message should not contain "invalid-key-three"
		And the message should contain "key-four"
		And the message should contain "key-five"
		And the message should contain "actions->causes->shortDescription"
		And the message should contain "Started by user gabe.westmaas"
		And the message should contain "actions->causes->userName"
		And the message should contain "building"
		And the message should contain "616063"
		And the message should contain "difference of -30000.0"
		And the message should contain "2014-03-07_16-23-27"
		And the message should contain "difference of 9899700000.0"

	Scenario: Compare jenkins_comparison_app (overhead) main load test invalid-key-one and key-one and invalid-key-three for status metrics
		When I post to "/jenkins_comparison_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"invalid-key-one+key-one+invalid-key-three", 
			"plugin_id": "JenkinsRestPlugin|||status"
		  }
		"""
		Then the response should be "200"
		And the message should not contain "key-one"
		And the message should not contain "invalid-key-one"
		And the message should not contain "invalid-key-three"

	Scenario: Compare jenkins_comparison_app (overhead) main load test key-one+key-four+key-two+key-five for unknown metrics
		When I post to "/jenkins_comparison_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-four+key-two+key-five", 
			"plugin_id": "JenkinsRestPlugin|||unknown"
		  }
		"""
		Then the response should be "404"
		And the error should match the "No data for JenkinsRestPlugin|||unknown found"

	Scenario: Compare jenkins_comparison_app (overhead) main invalid test key-one+key-two for status metrics
		When I post to "/jenkins_comparison_app/results/main/invalid/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two", 
			"plugin_id": "JenkinsRestPlugin|||status"
		  }
		"""
		Then the response should be "404"
		And the error should match the "No application by name of jenkins_comparison_app/invalid found"

	Scenario: Compare invalid main load test key-one and key-two for status metrics
		When I post to "/invalid/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two", 
			"plugin_id": "JenkinsRestPlugin|||status"
		  }
		"""
		Then the response should be "404"
		And the error should match the "No application by name of invalid/load_test found"

	Scenario: Compare jenkins_singular_app (singular) main load test key-one and key-two for status metrics
		When I post to "/jenkins_singular_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two", 
			"plugin_id": "JenkinsRestPlugin|||status"
		  }
		"""
		Then the response should be "200"
		And the message should contain "key-one"
		And the message should contain "key-two"
		And the message should contain "actions->causes->shortDescription"
		And the message should contain "Started by user gabe.westmaas"
		And the message should contain "actions->causes->userName"
		And the message should contain "building"
		And the message should contain "616063"
		And the message should contain "difference of -20000.0"
		And the message should contain "2014-03-07_16-23-27"
		And the message should contain "difference of -22500.0"

	Scenario: Compare jenkins_singular_app (singular) main load test key-one and key-two and key-three for status metrics
		When I post to "/jenkins_singular_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two+key-three", 
			"plugin_id": "JenkinsRestPlugin|||status"
		  }
		"""
		Then the response should be "200"
		And the message should contain "key-one"
		And the message should contain "key-two"
		And the message should contain "key-three"
		And the message should contain "actions->causes->shortDescription"
		And the message should contain "Started by user gabe.westmaas"
		And the message should contain "actions->causes->userName"
		And the message should contain "building"
		And the message should contain "616063"
		And the message should contain "difference of -20000.0"
		And the message should contain "2014-03-07_16-23-27"
		And the message should contain "difference of -22500.0"
		
	Scenario: Compare jenkins_singular_app (singular) main load test key-one and key-two for unknown metrics
		When I post to "/jenkins_singular_app/results/main/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two", 
			"plugin_id": "JenkinsRestPlugin|||unknown"
		  }
		"""
		Then the response should be "404"
		And the error should match the "No data for JenkinsRestPlugin|||unknown found"

	Scenario: Compare jenkins_singular_app (singular) main invalid test key-one and key-two for status metrics
		When I post to "/jenkins_singular_app/results/main/invalid/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two", 
			"plugin_id": "JenkinsRestPlugin|||status"
		  }
		"""
		Then the response should be "404"
		And the error should match the "No application by name of jenkins_singular_app/invalid found"
		
	Scenario: Compare jenkins_singular_app (singular) invalid load test key-one and key-two for status metrics
		When I post to "/jenkins_singular_app/results/invalid/load_test/compare-plugin" with:
		"""
		  {
			"compare":"key-one+key-two", 
			"plugin_id": "JenkinsRestPlugin|||status"
		  }
		"""
		Then the response should be "404"
		And the error should match the "No sub application for invalid found"