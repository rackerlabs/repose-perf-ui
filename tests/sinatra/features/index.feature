Feature: Index Page
	In order to navigate to home page
	As a performance test user
	I want to view the home page

	Scenario: Navigate to home page
		When I navigate to '/'
		Then the response should be "200"
		And the page should match the "index" version