Feature: Application Page
	In order to view applications
	As a performance test user
	I want to view the sub applications page for each application

	Scenario: Navigate to sub applications page of atom_hopper application
		When I navigate to '/atom_hopper/applications'
		Then the response should be "200"
		And the page should contain "main" applications

	Scenario: Navigate to sub applications page of invalid application
		When I navigate to '/invalid/applications'
		Then the response should be "404"

	Scenario: Navigate to main application
		When I navigate to '/atom_hopper/applications/main'
		Then the response should be "200"
		And the page should contain "config1_xml" configuration

	Scenario: Download main test runner file
		When I click on '/atom_hopper/applications/main/test_download/jmeter'
		Then the response should be "200"
		And the download page should match the "jmeter_main" version

	Scenario: Navigate to invalid sub application of atom_hopper application
		When I navigate to '/atom_hopper/applications/invalid'
		Then the response should be "404"

	Scenario: Navigate to invalid sub application of invalid application
		When I navigate to '/invalid/applications/invalid'
		Then the response should be "404"

	Scenario: Download invalid test runner file
		When I click on '/atom_hopper/applications/not_found/test_download/jmeter'
		Then the response should be "404"
		And the error page should match the "No test script exists for atom_hopper/not_found"

	Scenario: Download test runner file from invalid application
		When I click on '/invalid/applications/not_found/test_download/jmeter'
		Then the response should be "404"
		And the error page should match the "No test script exists for invalid/not_found"
		