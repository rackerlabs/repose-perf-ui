@tests
Feature: Test Page
	In order to view current tests
	As a performance test user
	I want to view the current tests page

	Scenario: Navigate to current tests page of file_comparison_app
		Given I navigate to '/file_comparison_app'
		When I click on "Running Tests"
		Then the page response status code should be "200"
		And the page should contain "main" applications

	Scenario: Navigate to sub applications page of invalid application
		When I navigate to '/invalid/tests'
		Then the page response status code should be "404"

	Scenario: Navigate to sub applications page of invalid application
		When I navigate to '/invalid/tests/main'
		Then the page response status code should be "404"

	Scenario: Navigate to main application
		When I navigate to '/file_comparison_app/tests/main'
		Then the page response status code should be "200"
		And the page should contain "Load Test"

	Scenario: Navigate to invalid application test page
		When I navigate to '/file_comparison_app/tests/invalid'
		Then the page response status code should be "404"

	Scenario: Navigate to invalid sub application of file_comparison_app application
		When I navigate to '/file_comparison_app/tests/invalid'
		Then the page response status code should be "404"

	Scenario: Navigate to invalid app load test application test page
		When I navigate to '/file_comparison_app/tests/invalid/load_test'
		Then the page response status code should be "404"

	Scenario: Navigate to main invalid test application test page
		When I navigate to '/file_comparison_app/tests/main/invalid_test'
		Then the page response status code should be "404"

	Scenario: Navigate to main adhoc test application test page
		When I navigate to '/file_comparison_app/tests/main/adhoc_test'
		Then the page response status code should be "200"
		And the page should contain "adhoc_test"
		And the page should contain "Test name"
		And the page should contain "Schedule new test"
		And the page should contain "Version:"
		And the page should contain "Test Type:"
		And the page should contain "Test Length in minutes"
		And the page should contain "Throughput in RPS"
		And the page should contain "Git Repository"

	Scenario: Navigate to main adhoc test application test page
		When I navigate to '/file_comparison_app/tests/main/load_test'
		Then the page response status code should be "200"
		And the page should contain "load_test"

	Scenario: Start recording REPOSE main test with custom name, custom description and defaults
		Given I navigate to '/repose/tests/main/adhoc_test'
		And Test for "file_comparison_app" "main" "adhoc"
		Then the page should contain "Schedule new test"
		And the page should contain "Test name"
		And the page should not contain "Current Test"
		When I fill in "test_name" with "custom name" within "body"
		And I fill in "description" with "custom description" within "body"
		And I click on "schedule_test"
		Then the page response status code should be "200"
		And the page should contain "Current Test"
		And the page should contain "Schedule new test"
		And the page should contain "runner"
		And the page should contain "custom name"
		And the page should contain "custom description"
		And the page should contain "runner"
		And the page should contain "jmeter"

	Scenario: Start recording main test with custom name, custom description and git repo
		Given I navigate to '/file_comparison_app/tests/main/adhoc_test'
		And Test for "file_comparison_app" "main" "adhoc"
		Then the page should contain "Schedule new test"
		And the page should contain "Test name"
		And the page should not contain "Current Test"
		When I fill in "test_name" with "custom name" within "body"
		And I fill in "description" with "custom description" within "body"
		And I select "Git" "versions"
		And I fill in "git_repo" with "https://github.com/dimtruck/hERmes_viewer" within "body"
		And I fill in "branch" with "master" within "body"
		And I click on "schedule_test"
		Then the page response status code should be "200"
		And the page should contain "Current Test"
		And the page should contain "Schedule new test"
		And the page should contain "runner"
		And the page should contain "custom name"
		And the page should contain "custom description"
		And the page should contain "https://github.com/dimtruck/hERmes_viewer"
		And the page should contain "master"
		And the page should contain "runner"
		And the page should contain "jmeter"

	Scenario: Start recording main test with custom name, custom description and custom test type
		Given I navigate to '/file_comparison_app/tests/main/adhoc_test'
		And Test for "file_comparison_app" "main" "adhoc"
		Then the page should contain "Schedule new test"
		And the page should contain "Test name"
		And the page should not contain "Current Test"
		When I fill in "test_name" with "custom name" within "body"
		And I fill in "description" with "custom description" within "body"
		And I select "Custom" "test_type"
		And I fill in "length" with "60" within "body"
		And I fill in "throughput" with "120" within "body"
		And I click on "schedule_test"
		Then the page response status code should be "200"
		And the page should contain "Current Test"
		And the page should contain "Schedule new test"
		And the page should contain "runner"
		And the page should contain "custom name"
		And the page should contain "custom description"
		And the page should contain "60"
		And the page should contain "120"
		And the page should contain "length"
		And the page should contain "throughput"
		And the page should contain "runner"
		And the page should contain "jmeter"
