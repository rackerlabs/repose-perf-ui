@index
Feature: Index Page
	In order to navigate to home page
	As a performance test user
	I want to view the home page

	Scenario: Navigate to home page
		When I navigate to '/'
		Then the page response status code should be "200"
		And the page should contain "comparison_app,overhead,sysstats,repose_comparison_app,repose_singular_app" application list
		
	Scenario: Navigate to application home page
	    When I navigate to '/comparison_app'
	    Then the page response status code should be "200"
	    And the page should contain the "/comparison_app/tests" link
	    And the page should contain the "/comparison_app/results" link
	    And the page should contain the "/comparison_app/applications" link
	    And the page should contain the "Applications can be configured by users.  You can view application setup here and can set up/edit/delete your application." paragraph
		
	Scenario: Navigate to invalid application home page
	    When I navigate to '/invalid'
	    Then the page response status code should be "404"   