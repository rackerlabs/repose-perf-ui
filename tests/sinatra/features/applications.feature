Feature: Application Page
	In order to view applications
	As a performance test user
	I want to view the application page

	Scenario: Navigate to applications page
		When I navigate to '/applications'
		Then the response should be "200"
		And the page should contain "dbaas,ah,csl,passthrough,ddrl,metrics_on_off" applications

	Scenario: Navigate to dbaas application
		When I navigate to '/applications/dbaas'
		Then the response should be "200"
		And the page should contain "container_cfg_xml,client_auth_n_cfg_xml,content_normalization_cfg_xml,translation_cfg_xml" configuration

	Scenario: Download dbaas test runner file
		When I click on '/applications/dbaas/test_download/test_dbaas.jmx'
		Then the response should be "200"
		And the download page should match the "jmeter_dbaas" version

	Scenario: Navigate to ah application
		When I navigate to '/applications/ah'
		Then the response should be "200"
		And the page should contain "container_cfg_xml,client_auth_n_cfg_xml,rate_limiting_cfg_xml,translation_cfg_xml" configuration

	Scenario: Download ah test runner file
		When I click on '/applications/ah/test_download/test_ah.jmx'
		Then the response should be "200"
		And the download page should match the "jmeter_ah" version

	Scenario: Navigate to invalid application
		When I navigate to '/applications/invalid'
		Then the response should be "404"

	Scenario: Download invalid test runner file
		When I click on '/applications/not_found/test_download/test_not_found.jmx'
		Then the response should be "404"
		And the error page should match the "No test file exists for not_found"
