require 'test/unit'
require 'yaml'
require './Models/test.rb'

class TestTest < Test::Unit::TestCase
  def setup
    @app = "test_app"
    @sub_app = "test_sub_app"
    @config = YAML.load_file(File.expand_path("config/test_config.yaml", Dir.pwd))
    @store = {:host => @config['redis']['host'], :port => @config['redis']['port'], :db => @config['redis']['db']}
    @redis = Redis.new(@store)
    @redis.set("#{@app}:#{@sub_app}:tests:setup:request_response:request","[{\"method\":\"GET\",\"uri\":\"/\",\"headers\":[\"x-auth: blah\"],\"body\":\"test\"},{\"method\":\"POST\",\"uri\":\"/v1\",\"headers\":[],\"body\":\"test 2\"}]")
    @redis.set("#{@app}:#{@sub_app}:tests:setup:request_response:response","[{\"response_code\":201,\"body\":\"201\"},{\"response_code\":200, \"sample\":\"response2\"}]")
  end

  def teardown
    @redis.del("#{@app}:#{@sub_app}:tests:setup:request_response:request")
    @redis.del("#{@app}:#{@sub_app}:tests:setup:request_response:response")
  end

  def test_get_setup_requests_by_name
    test = SnapshotComparer::Models::Test.new(@store).get_setup_requests_by_name(@app,@sub_app)
    assert_not_nil(test, "Test construction failed.")
    assert_equal(2,test.length)
    assert_equal(2,test[0].length)
    assert_equal(2,test[1].length)
    assert_equal("test",test[0][0].body)
    assert_equal(["x-auth: blah"],test[0][0].headers)
    assert_equal("GET",test[0][0].method)
    assert_equal("/",test[0][0].uri)
    assert_equal(201,test[0][1].response_code)
    assert_equal("test 2",test[1][0].body)
    assert_equal([],test[1][0].headers)
    assert_equal("POST",test[1][0].method)
    assert_equal("/v1",test[1][0].uri)
    assert_equal(200,test[1][1].response_code)
  end

  def test_get_setup_requests_by_name_no_name
    assert_raise(ArgumentError,"required requests and response jsons are not available.  These files are required to let users know what execution happens during a test run.") do
      test = SnapshotComparer::Models::Test.new(@store).get_setup_requests_by_name(nil,@sub_app)
    end
  end

  def test_get_by_name_name_dne
    assert_raise(ArgumentError,"required requests and response jsons are not available.  These files are required to let users know what execution happens during a test run.") do
      test = SnapshotComparer::Models::Test.new(@store).get_setup_requests_by_name("invalid_app",@sub_app)
    end
  end
end

