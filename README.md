hERmes_viewer
=============

hERmes is an aggregation tool for disparate data for analytical purposes.  It takes various performance test information (e.g. Graphite, application server, logs, Nagios, custom counters) and wraps them in a single container.  That container can then be compared to other containers for trending analysis.  hERmes also provides a way to assert SLA metrics, reader's digest, and custom plugin architecture.

<h2>Installation</h2>
- Install ruby 2.0
- Install bundler
- Install application dependencies:
    <code>bundle install</code>
- Start application:
    <code>rackup</code>

<h2>Testing</h2>
<h3>Setup</h3>
Install redis and lighttpd and configure your test_config.yaml and test_atom_hopper.yaml
- Example for test_config.yaml:

```
redis:
  host: localhost
  port: 6379
  db: 1
file_store: localhost  
test_list:
  load_test:
    name: Load Test
    description: Test running for a sample duration at 120% of expected load for the application.
  duration_test:
    name: Duration Test
    description: Test running for a a longer duration than average (optimally 12 to 48 hours at 75% expected load)
  stress_test:
    name: Stress Test
    description: Test running with constant increasing load until application fails
  adhoc_test:
    name: Adhoc Test
    description: Test with custom settings.  A one-time only iteration
```

- Example for test_atom_hopper.yaml

```
application:
  name: Atom Hopper
  description: atom feed applications that acts as a repository for feeds from other projects
  location: apps/atom_hopper/bootstrap.rb
  type: singular
  plugins:
   - location: plugins/mac_perf_mon/plugin.rb
  sub_apps: 
   - 
     id: main
     name: Main application
     description: This is the base configuration for Atom Hopper

```

Load dump.rdb for redis and lighttpd_store.zip for lighttpd for test data setup


<h3>Execution</h3>
hERmes has extensive testing with Cucumber (<code>cucumber tests/</code>) and unit test (<code>ruby tests/Models/test_helper.rb</code>).  The code coverage is compiled by simplecov.

<h2>Data store configuration</h2>
- Starting and stopping recordings:

      ```
      [application_name]:test:[unique_id]:[sub_application]:[test_type]:start
      ```
      
      - stores timestamp
      
- Test requests and responses:

      ```
      [application_name]:[sub_application]:tests:setup:request_response:request
      [application_name]:[sub_application]:tests:setup:request_response:response
      ```
      
      - stores json object of each entry (request or response)
	  - EXAMPLE:
	  
	  ```
      > get app:sub_app:tests:setup:request_response:request
      "[  {    \"request_id\": 1,    \"method\": \"GET\",    \"uri\": \"/v1.0/{user}/flavors\",    \"headers\": [      \"x-auth-token: valid-admin-token${user}\",      \"x-auth-project-id: test\",      \"accept: application/json\"    ]  },  {    \"request_id\": 2,    \"method\": \"GET\",    \"uri\": \"/v1.0/{user}/limits\",    \"headers\": [      \"x-auth-token: valid-admin-token${user}\",      \"x-auth-project-id: test\",      \"accept: application/json\"    ]  }]"
      > get app:sub_app:tests:setup:request_response:response
      "[  {    \"request_id\": 1,    \"response_code\": 200  },  {    \"request_id\": 2,    \"response_code\": 200  }]"
	  ```

- Test configurations:

      ```
      [application_name]:[sub_application]:setup:configs
      ```
      
      - stores a list of json objects of each configuration (name, location)
	  - EXAMPLE:
	  
	  ```
      > lrange "app:sub_app:setup:configs" 0 -1
      1) "{\"name\":\"config1.xml\",\"location\":\"/files/app/sub_app/setup/configs/config1.xml\"}"
	  ```

- Test script:

      ```
      [application_name]:[sub_application]:tests:setup:script
      ```
      
      - stores a hash of test (json object of location where the script is located) and type (type of runner)
	  - EXAMPLE:
	  
	  ```
      > hkeys "app:sub_app:tests:setup:script"
      1) "test"
	  2) "type"
      > hget "atom_hopper:main:tests:setup:script" test
      "{\"name\":\"test.jmx\",\"location\":\"/files/app/sub_app/setup/meta/test.jmx\"}"
      > hget "atom_hopper:main:tests:setup:script" type
      "jmeter"
	  ```

- Results guid list:

    ```
    [application_name]:[sub_application]:results:[test_type]
    ```
    
    - stores a list of guids for each test execution
    - EXAMPLE

    ```
    > lrange "atom_hopper:main:results:load" 0 -1
    1) "e464b1b6-10ab-4332-8b30-8439496c2d19"  
    ```

- Results meta:

    ```
    [application_name]:[sub_application]:results:[test_type]:[guid]:meta
    ```
    
    - stores a hash of keys and values for meta information for that test execution.  The following keys are REQUIRED (there can be many more optional keys)

        -  test -> json object with test information
        
            - node_count - number of nodes used for testing
            - runner - which runner was used to generate load
            - start - ticks of when test started
            - stop - ticks of when test stopped
            - description - description of the test.  For comparison apps, this describes the difference between the two tests
            - comparison_guid - for comparison apps, this is used to map the other guid.  The two tests that are to be combined must link to each other.  Only present for comparison apps (where you always want to check overhead)
            - name - name of the test.
                
        - request -> json object with request information
        - response -> json object with response information
        - script -> json object with the location to the script
        - test_[runner] -> json object with the specific information for runners
        
    - EXAMPLE

    ```
	> hkeys "atom_hopper:main:results:load:e464b1b6-10ab-4332-8b30-8439496c2d19:meta"
	1) "jmxparams"
	2) "test"
	3) "responders"
	4) "request"
	5) "script"
	6) "test_jmeter"
	7) "response"

	> hget "app:sub_app:results:load:e464b1b6-10ab-4332-8b30-8439496c2d19:meta" test
	"{  \"node_count\": 2,  \"runner\":\"jmeter\",  \"start\":\"1383764473000\",  \"stop\":\"1383768073000\",  \"description\" : \"adhoc test with performance flavor #1 with Repose\",  \"name\" : \"jenkins-repose-pt-static-adhoc-231\"}"

	> hget "app:sub_app:results:load:e464b1b6-10ab-4332-8b30-8439496c2d19:meta" request
	"[  {    \"request_id\": 1,    \"method\": \"GET\",    \"uri\": \"/v1.0/{user}/flavors\",    \"headers\": [      \"x-auth-token: valid-admin-token${user}\",      \"x-auth-project-id: test\",      \"accept: application/json\"    ]  },  {    \"request_id\": 2,    \"method\": \"GET\",    \"uri\": \"/v1.0/{user}/limits\",    \"headers\": [      \"x-auth-token: valid-admin-token${user}\",      \"x-auth-project-id: test\",      \"accept: application/json\"    ]  }]"

	> hget "app:sub_app:results:load:e464b1b6-10ab-4332-8b30-8439496c2d19:meta" response
	"[  {    \"request_id\": 1,    \"response_code\": 200  },  {    \"request_id\": 2,    \"response_code\": 200  }]"

	> hget "app:sub_app:results:load:e464b1b6-10ab-4332-8b30-8439496c2d19:meta" script
	"{\"name\":\"test.jmx\",\"location\":\"/files/app/sub_app/results/load/e464b1b6-10ab-4332-8b30-8439496c2d19/meta/test.jmx\", \"type\":\"jmeter\"}"
	
	> hget "app:sub_app:results:load:e464b1b6-10ab-4332-8b30-8439496c2d19:meta" test_jmeter
	"{  \"threads\":20,  \"rampup\":1800}"
    ```
    
- Results configs

    ```
    [application_name]:[sub_application]:results:[test_type]:[guid]:configs
    ```
    
    - stores a list of json objects with paths to configs for the test execution
        
    - EXAMPLE

    ```
	> lrange "app:sub_app:results:load:e464b1b6-10ab-4332-8b30-8439496c2d19:configs" 0 -1
	1) "{\"name\":\"config1.xml\",\"location\":\"/files/app/sub_app/results/load/e464b1b6-10ab-4332-8b30-8439496c2d19/configs/config1.xml\"}"
    ```
    
- Results data

    ```
    [application_name]:[sub_application]:results:[test_type]:[guid]:data
    ```
    
    - stores a hash of keys to results.  Results key is the only key required; however, various plugins should store data here
        
    - EXAMPLE

    ```
	> hkeys "app:sub_app:results:load:e464b1b6-10ab-4332-8b30-8439496c2d19:data"
	1) "results"
	
	> hget "app:sub_app:results:load:e464b1b6-10ab-4332-8b30-8439496c2d19:data" results
	"{\"name\":\"summary.log\",\"location\":\"/files/app/sub_app/results/load/e464b1b6-10ab-4332-8b30-8439496c2d19/data/summary.log\"}"
    ```
