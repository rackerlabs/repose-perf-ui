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
hERmes has extensive testing with Cucumber (<code>cucumber tests/</code>) and unit test (<code>ruby tests/Models/test_helper.rb</code>).  The code coverage is compiled by simplecov.

<h2>Data store configuration</h2>
- Starting and stopping recordings:

      ```
      [application_name]:test:[unique_id]:[sub_application]:[test_type]:start
      ```
      
      - stores timestamp
      
- Test configurations:

      ```
      [application_name]:[sub_application]:tests:setup:main:request_response
      ```
      
      - stores a hash of key (request or response) and value (json object of request/response)
	  - EXAMPLE:
	  
	  ```
      > hgetall app:sub_app:tests:setup:main:request_response
      1) "response_0"
	  2) "{\"response_code\":\"201\"}"
	  3) "request_0"
	  4) "{\"request_id\":1,\"method\":\"POST\",\"uri\":\"/event\",\"body\":\"{\"name\":\"test\"}\",\"headers\":[\"X-Auth-Token: valid-token\",\"Content-Type: application/json\"]}"
	  5) "response_1"
	  6) "{\"response_code\":200}"
	  7) "request_1"
	  8) "{\"request_id\":2,\"method\":\"GET\",\"uri\":\"/event?limit=100\",\"headers\":[\"X-Auth-Token: valid-token\"]}"
	  ```
- Application configurations (list):

    ```
    [application_name]:[sub_application]:configs:main
    ```
    
    - stores a list of json objects with name, location (always relative), and content (base64 encoded)
    - EXAMPLE
    

	    ```
	    > lrange app:sub_app:configs:main 0 -1
	    1) "{\"name\":\"config_one.xml\",\"location\":\"/\",\"data\":\"PHJhdGUtbGltaXRpbmcgZGF0YXN0b3JlPSJkaXN0cmlidXRlZC9oYXNoLXJpbmciIHVzZS1jYXB0dXJlLWdyb3Vwcz0iZmFsc2UiIHhtbG5zPSJodHRwOi8vZG9jcy5yYWNrc3BhY2VjbG91ZC5jb20vcmVwb3NlL3JhdGUtbGltaXRpbmcvdjEuMCI+DQogICA8cmVxdWVzdC1lbmRwb2ludCB1cmktcmVnZXg9Ii9saW1pdHMiIGluY2x1ZGUtYWJzb2x1dGUtbGltaXRzPSJmYWxzZSIgLz4NCiANCiAgIDxsaW1pdC1ncm91cCBpZD0ibGltaXRlZCIgZ3JvdXBzPSJCRVRBX0dyb3VwIElQX1N0YW5kYXJkIiBkZWZhdWx0PSJmYWxzZSI+DQogICAgICA8bGltaXQgdXJpPSIqIiB1cmktcmVnZXg9Ii9zb21ldGhpbmcvKC4qKSIgaHR0cC1tZXRob2RzPSJQVVQiIHVuaXQ9Ik1JTlVURSIgdmFsdWU9IjEwIiAvPg0KICAgICAgPGxpbWl0IHVyaT0iKiIgdXJpLXJlZ2V4PSIvc29tZXRoaW5nLyguKikiIGh0dHAtbWV0aG9kcz0iR0VUIiB1bml0PSJNSU5VVEUiIHZhbHVlPSIxMCIgLz4NCiAgIDwvbGltaXQtZ3JvdXA+DQogDQogIDxsaW1pdC1ncm91cCBpZD0ibGltaXRlZC1hbGwiIGdyb3Vwcz0iTXlfR3JvdXAiIGRlZmF1bHQ9InRydWUiPg0KICAgICAgPGxpbWl0IHVyaT0iKiIgdXJpLXJlZ2V4PSIvc29tZXRoaW5nLyguKikiIGh0dHAtbWV0aG9kcz0iQUxMIiB1bml0PSJIT1VSIiB2YWx1ZT0iMTAiIC8+DQogICA8L2xpbWl0LWdyb3VwPg0KPC9yYXRlLWxpbWl0aW5nPg==\"}"  
        ```
