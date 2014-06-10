require  './Models/test.rb'

class TestTest < Test::Unit::TestCase
	def setup
		@config = YAML.load_file(File.expand_path("../../../config/config.yaml", __FILE__))
	end

	def test_get_results_requests_by_file_location
		test = Models::Test.new.get_results_requests_by_file_location("#{@config['home_dir']}/files/apps/unit_test/results/adhoc/current")
		assert_not_nil(test, "Test construction failed.")
		assert_equal(2,test.length)
		assert_equal(2,test[0].length)
		assert_equal(2,test[1].length)
		assert_equal("&lt;?xml version=&apos;1.0&apos; encoding=&apos;UTF-8&apos;?&gt; &lt;?atom feed=&apos;usagetest1/events&apos;?&gt; &lt;atom:entry xmlns:atom=&apos;http://www.w3.org/2005/Atom&apos;&gt;     &lt;atom:content type=&apos;application/xml&apos;&gt;         &lt;event xmlns=&apos;http://docs.rackspace.com/core/event&apos;                xmlns:widget=&apos;http://docs.rackspace.com/usage/widget&apos;                version=&apos;1&apos; tenantId=&apos;12334&apos;                resourceId=&apos;4a2b42f4-6c63-11e1-815b-7fcbcf67f549&apos;                id=&apos;${__BeanShell(UUID.randomUUID().toString())}&apos;                type=&apos;UPDATE&apos; dataCenter=&apos;DFW1&apos; region=&apos;DFW&apos;                startTime=&apos;2012-03-12T11:51:11Z&apos;                endTime=&apos;2012-03-12T15:51:11Z&apos;&gt;             &lt;widget:product version=&apos;3&apos; label=&apos;Test Label&apos;                             serviceCode=&apos;Widget&apos;                             resourceType=&apos;THINGY&apos;                             mid=&apos;94c61976-9f4c-11e1-bddf-ab57017a9899&apos;&gt;                 &lt;widget:metaData key=&apos;foo&apos; value=&apos;bar&apos;/&gt;                 &lt;widget:metaData key=&apos;fruit&apos; value=&apos;loops&apos;/&gt;             &lt;/widget:product&gt;         &lt;/event&gt;     &lt;/atom:content&gt; &lt;/atom:entry&gt;",test[0][0].body)
		assert_equal(["X-Auth-Token: valid-token", "Content-Type: application/atom+xml"],test[0][0].headers)
		assert_equal("POST",test[0][0].method)
		assert_equal("/melange/events",test[0][0].uri)
		assert_equal(201,test[0][1].response_code)
		assert_equal("",test[1][0].body)
		assert_equal(["X-Auth-Token: valid-token", "Content-Type: application/atom+xml"],test[1][0].headers)
		assert_equal("GET",test[1][0].method)
		assert_equal("/melange/events?limit=1000",test[1][0].uri)
		assert_equal(200,test[1][1].response_code)
	end

	def test_get_results_requests_by_file_location_location_dne
		test = Models::Test.new.get_results_requests_by_file_location("#{@config['home_dir']}/files/apps/unit_test_dne/results/adhoc/current")
		assert_not_nil(test, "Test construction failed.")
		assert_equal([],test)
	end

	def test_get_results_requests_by_file_location_no_result_dir
		test = Models::Test.new.get_results_requests_by_file_location("#{@config['home_dir']}/files/apps/unit_test_no_result_dir/results/adhoc/current")
		assert_not_nil(test, "Test construction failed.")
		assert_equal([],test)
	end

	def test_get_results_requests_by_file_location_no_test_type_dir
		test = Models::Test.new.get_results_requests_by_file_location("#{@config['home_dir']}/files/apps/unit_test_no_result_adhoc_dir/results/adhoc/current")
		assert_not_nil(test, "Test construction failed.")
		assert_equal([],test)
	end

	def test_get_results_requests_by_file_location_no_test_instance_dir
		test = Models::Test.new.get_results_requests_by_file_location("#{@config['home_dir']}/files/apps/unit_test_no_result_current_dir/results/adhoc/current")
		assert_not_nil(test, "Test construction failed.")
		assert_equal([],test)
	end

	def test_get_results_requests_by_file_location_no_meta_dir
		test = Models::Test.new.get_results_requests_by_file_location("#{@config['home_dir']}/files/apps/unit_test_no_config_dir/results/adhoc/current")
		assert_not_nil(test, "Test construction failed.")
		assert_equal([],test)
	end

	def test_get_results_requests_by_file_location_no_response
		test = Models::Test.new.get_results_requests_by_file_location("#{@config['home_dir']}/files/apps/unit_test_empty_config_main_dir/results/adhoc/current")
		assert_not_nil(test, "Test construction failed.")
		assert_equal(2,test.length)
		assert_equal(2,test[0].length)
		assert_equal(2,test[1].length)
		assert_equal("&lt;?xml version=&apos;1.0&apos; encoding=&apos;UTF-8&apos;?&gt; &lt;?atom feed=&apos;usagetest1/events&apos;?&gt; &lt;atom:entry xmlns:atom=&apos;http://www.w3.org/2005/Atom&apos;&gt;     &lt;atom:content type=&apos;application/xml&apos;&gt;         &lt;event xmlns=&apos;http://docs.rackspace.com/core/event&apos;                xmlns:widget=&apos;http://docs.rackspace.com/usage/widget&apos;                version=&apos;1&apos; tenantId=&apos;12334&apos;                resourceId=&apos;4a2b42f4-6c63-11e1-815b-7fcbcf67f549&apos;                id=&apos;${__BeanShell(UUID.randomUUID().toString())}&apos;                type=&apos;UPDATE&apos; dataCenter=&apos;DFW1&apos; region=&apos;DFW&apos;                startTime=&apos;2012-03-12T11:51:11Z&apos;                endTime=&apos;2012-03-12T15:51:11Z&apos;&gt;             &lt;widget:product version=&apos;3&apos; label=&apos;Test Label&apos;                             serviceCode=&apos;Widget&apos;                             resourceType=&apos;THINGY&apos;                             mid=&apos;94c61976-9f4c-11e1-bddf-ab57017a9899&apos;&gt;                 &lt;widget:metaData key=&apos;foo&apos; value=&apos;bar&apos;/&gt;                 &lt;widget:metaData key=&apos;fruit&apos; value=&apos;loops&apos;/&gt;             &lt;/widget:product&gt;         &lt;/event&gt;     &lt;/atom:content&gt; &lt;/atom:entry&gt;",test[0][0].body)
		assert_equal(["X-Auth-Token: valid-token", "Content-Type: application/atom+xml"],test[0][0].headers)
		assert_equal("POST",test[0][0].method)
		assert_equal("/melange/events",test[0][0].uri)
		assert_nil(test[0][1])
		assert_equal("",test[1][0].body)
		assert_equal(["X-Auth-Token: valid-token", "Content-Type: application/atom+xml"],test[1][0].headers)
		assert_equal("GET",test[1][0].method)
		assert_equal("/melange/events?limit=1000",test[1][0].uri)
		assert_nil(test[1][1])
	end

	def test_get_results_requests_by_file_location_no_request
		test = Models::Test.new.get_results_requests_by_file_location("#{@config['home_dir']}/files/apps/unit_test_empty_no_request/results/adhoc/current")
		assert_not_nil(test, "Test construction failed.")
		assert_equal([],test)
	end

	def test_get_setup_requests_by_name
		test = Models::Test.new.get_setup_requests_by_name("unit_test")
		assert_not_nil(test, "Test construction failed.")
		assert_equal(2,test.length)
		assert_equal(2,test[0].length)
		assert_equal(2,test[1].length)
		assert_equal("&lt;?xml version=&apos;1.0&apos; encoding=&apos;UTF-8&apos;?&gt; &lt;?atom feed=&apos;usagetest1/events&apos;?&gt; &lt;atom:entry xmlns:atom=&apos;http://www.w3.org/2005/Atom&apos;&gt;     &lt;atom:content type=&apos;application/xml&apos;&gt;         &lt;event xmlns=&apos;http://docs.rackspace.com/core/event&apos;                xmlns:widget=&apos;http://docs.rackspace.com/usage/widget&apos;                version=&apos;1&apos; tenantId=&apos;12334&apos;                resourceId=&apos;4a2b42f4-6c63-11e1-815b-7fcbcf67f549&apos;                id=&apos;${__BeanShell(UUID.randomUUID().toString())}&apos;                type=&apos;UPDATE&apos; dataCenter=&apos;DFW1&apos; region=&apos;DFW&apos;                startTime=&apos;2012-03-12T11:51:11Z&apos;                endTime=&apos;2012-03-12T15:51:11Z&apos;&gt;             &lt;widget:product version=&apos;3&apos; label=&apos;Test Label&apos;                             serviceCode=&apos;Widget&apos;                             resourceType=&apos;THINGY&apos;                             mid=&apos;94c61976-9f4c-11e1-bddf-ab57017a9899&apos;&gt;                 &lt;widget:metaData key=&apos;foo&apos; value=&apos;bar&apos;/&gt;                 &lt;widget:metaData key=&apos;fruit&apos; value=&apos;loops&apos;/&gt;             &lt;/widget:product&gt;         &lt;/event&gt;     &lt;/atom:content&gt; &lt;/atom:entry&gt;",test[0][0].body)
		assert_equal(["X-Auth-Token: valid-token", "Content-Type: application/atom+xml"],test[0][0].headers)
		assert_equal("POST",test[0][0].method)
		assert_equal("/melange/events",test[0][0].uri)
		assert_equal(201,test[0][1].response_code)
		assert_equal("",test[1][0].body)
		assert_equal(["X-Auth-Token: valid-token", "Content-Type: application/atom+xml"],test[1][0].headers)
		assert_equal("GET",test[1][0].method)
		assert_equal("/melange/events?limit=1000",test[1][0].uri)
		assert_equal(200,test[1][1].response_code)
	end

	def test_get_setup_requests_by_name_no_name
		test = Models::Test.new.get_setup_requests_by_name(nil)
		assert_not_nil(test, "Test construction failed.")
		assert_equal([],test)
	end

	def test_get_by_name_name_dne
		test = Models::Test.new.get_setup_requests_by_name("unit_test_dne")
		assert_not_nil(test, "Test construction failed.")
		assert_equal([],test)
	end

	def test_get_by_name_no_tests_dir
		test = Models::Test.new.get_setup_requests_by_name("unit_test_no_tests_dir")
		assert_not_nil(test, "Test construction failed.")
		assert_equal([],test)
	end

	def test_get_by_name_no_setup_dir
		test = Models::Test.new.get_setup_requests_by_name("unit_test_no_setup_dir")
		assert_not_nil(test, "Test construction failed.")
		assert_equal([],test)
	end

	def test_get_by_name_no_main_dir
		test = Models::Test.new.get_setup_requests_by_name("unit_test_no_main_dir")
		assert_not_nil(test, "Test construction failed.")
		assert_equal([],test)
	end

	def test_get_by_name_no_request
		test = Models::Test.new.get_setup_requests_by_name("unit_test_empty_only_response_dir")
		assert_not_nil(test, "Configuration construction failed.")
		assert_equal([],test)
	end

	def test_get_by_name_no_response
		test = Models::Test.new.get_setup_requests_by_name("unit_test_empty_only_request_dir")
		assert_not_nil(test, "Test construction failed.")
		assert_equal(2,test.length)
		assert_equal(2,test[0].length)
		assert_equal(2,test[1].length)
		assert_equal("&lt;?xml version=&apos;1.0&apos; encoding=&apos;UTF-8&apos;?&gt; &lt;?atom feed=&apos;usagetest1/events&apos;?&gt; &lt;atom:entry xmlns:atom=&apos;http://www.w3.org/2005/Atom&apos;&gt;     &lt;atom:content type=&apos;application/xml&apos;&gt;         &lt;event xmlns=&apos;http://docs.rackspace.com/core/event&apos;                xmlns:widget=&apos;http://docs.rackspace.com/usage/widget&apos;                version=&apos;1&apos; tenantId=&apos;12334&apos;                resourceId=&apos;4a2b42f4-6c63-11e1-815b-7fcbcf67f549&apos;                id=&apos;${__BeanShell(UUID.randomUUID().toString())}&apos;                type=&apos;UPDATE&apos; dataCenter=&apos;DFW1&apos; region=&apos;DFW&apos;                startTime=&apos;2012-03-12T11:51:11Z&apos;                endTime=&apos;2012-03-12T15:51:11Z&apos;&gt;             &lt;widget:product version=&apos;3&apos; label=&apos;Test Label&apos;                             serviceCode=&apos;Widget&apos;                             resourceType=&apos;THINGY&apos;                             mid=&apos;94c61976-9f4c-11e1-bddf-ab57017a9899&apos;&gt;                 &lt;widget:metaData key=&apos;foo&apos; value=&apos;bar&apos;/&gt;                 &lt;widget:metaData key=&apos;fruit&apos; value=&apos;loops&apos;/&gt;             &lt;/widget:product&gt;         &lt;/event&gt;     &lt;/atom:content&gt; &lt;/atom:entry&gt;",test[0][0].body)
		assert_equal(["X-Auth-Token: valid-token", "Content-Type: application/atom+xml"],test[0][0].headers)
		assert_equal("POST",test[0][0].method)
		assert_equal("/melange/events",test[0][0].uri)
		assert_nil(test[0][1])
		assert_equal("",test[1][0].body)
		assert_equal(["X-Auth-Token: valid-token", "Content-Type: application/atom+xml"],test[1][0].headers)
		assert_equal("GET",test[1][0].method)
		assert_equal("/melange/events?limit=1000",test[1][0].uri)
		assert_nil(test[1][1])
	end

	def test_get_by_name_empty_request
		test = Models::Test.new.get_setup_requests_by_name("unit_test_empty_request")
		assert_not_nil(test, "Configuration construction failed.")
		assert_equal([],test)
	end

	def test_get_by_name_empty_response
		test = Models::Test.new.get_setup_requests_by_name("unit_test_empty_response")
		assert_not_nil(test, "Configuration construction failed.")
		assert_equal(2,test.length)
		assert_equal(2,test[0].length)
		assert_equal(2,test[1].length)
		assert_equal("&lt;?xml version=&apos;1.0&apos; encoding=&apos;UTF-8&apos;?&gt; &lt;?atom feed=&apos;usagetest1/events&apos;?&gt; &lt;atom:entry xmlns:atom=&apos;http://www.w3.org/2005/Atom&apos;&gt;     &lt;atom:content type=&apos;application/xml&apos;&gt;         &lt;event xmlns=&apos;http://docs.rackspace.com/core/event&apos;                xmlns:widget=&apos;http://docs.rackspace.com/usage/widget&apos;                version=&apos;1&apos; tenantId=&apos;12334&apos;                resourceId=&apos;4a2b42f4-6c63-11e1-815b-7fcbcf67f549&apos;                id=&apos;${__BeanShell(UUID.randomUUID().toString())}&apos;                type=&apos;UPDATE&apos; dataCenter=&apos;DFW1&apos; region=&apos;DFW&apos;                startTime=&apos;2012-03-12T11:51:11Z&apos;                endTime=&apos;2012-03-12T15:51:11Z&apos;&gt;             &lt;widget:product version=&apos;3&apos; label=&apos;Test Label&apos;                             serviceCode=&apos;Widget&apos;                             resourceType=&apos;THINGY&apos;                             mid=&apos;94c61976-9f4c-11e1-bddf-ab57017a9899&apos;&gt;                 &lt;widget:metaData key=&apos;foo&apos; value=&apos;bar&apos;/&gt;                 &lt;widget:metaData key=&apos;fruit&apos; value=&apos;loops&apos;/&gt;             &lt;/widget:product&gt;         &lt;/event&gt;     &lt;/atom:content&gt; &lt;/atom:entry&gt;",test[0][0].body)
		assert_equal(["X-Auth-Token: valid-token", "Content-Type: application/atom+xml"],test[0][0].headers)
		assert_equal("POST",test[0][0].method)
		assert_equal("/melange/events",test[0][0].uri)
		assert_nil(test[0][1])
		assert_equal("",test[1][0].body)
		assert_equal(["X-Auth-Token: valid-token", "Content-Type: application/atom+xml"],test[1][0].headers)
		assert_equal("GET",test[1][0].method)
		assert_equal("/melange/events?limit=1000",test[1][0].uri)
		assert_nil(test[1][1])
	end
end

