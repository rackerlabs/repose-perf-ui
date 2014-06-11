require  './Models/testlocation.rb'
require 'test/unit'
require 'yaml'
require 'redis'
require 'fileutils'
require 'securerandom'

class TestLocationTest < Test::Unit::TestCase
  def setup
    @href = "myuri"
    @type = "load"
  end

  def test_initialize
    testlocation = SnapshotComparer::Models::TestLocation.new(@href,@type)
    assert_not_nil(testlocation, "testlocation construction failed")
    assert_equal(@href, testlocation.href)
    assert_equal(@type, testlocation.type)
  end

  def test_download
    testlocation = SnapshotComparer::Models::TestLocation.new(@href,@type)
    assert_not_nil(testlocation, "testlocation construction failed")
    download = testlocation.download
    assert_equal(@href, download)
  end
end

class TestLocationFactoryTest < Test::Unit::TestCase

  def setup
    @app = "test_app"
    @sub_app = "test_sub_app"
    @config = YAML.load_file(File.expand_path("config/test_config.yaml", Dir.pwd))
    @store = {:host => @config['redis']['host'], :port => @config['redis']['port'], :db => @config['redis']['db']}
    @fs_ip = @config['file_store']
    @redis = Redis.new(@store)
    @redis.lpush("#{@app}:#{@sub_app}:tests:setup:script","{\"type\":\"load\",\"test\":\"jmeter\",\"location\":\"some_location\"}")
    @redis.set("#{@app}:#{@sub_app}:tests:setup:request_response:response","[{\"response_code\":201,\"body\":\"201\"},{\"response_code\":200, \"sample\":\"response2\"}]")
  end

  def teardown
    @redis.lrem("#{@app}:#{@sub_app}:tests:setup:script")
    @redis.del("#{@app}:#{@sub_app}:tests:setup:request_response:response")
  end

  def test_get_by_name
    test = SnapshotComparer::Models::TestLocationFactory.new(@store,@fs_ip).get_by_name(@app, @sub_app)
    assert_not_nil(test, "Test construction failed.")
    assert_equal("test_custom.jmx",test.href)
    assert_equal(:jmeter,test.type)
    assert_equal("/Users/dimi5963/projects/repose_pt/files/apps/unit_test/tests/setup/main",test.test_location_dir)
  end

  def test_get_by_name_app_name_dne
    assert_raise ArgumentError do
      test = SnapshotComparer::Models::TestLocationFactory.get_by_name("unit_test_dne")
    end
  end

  def test_get_by_name_no_tests_dir
    assert_raise ArgumentError do
      test = SnapshotComparer::Models::TestLocationFactory.get_by_name("unit_test_no_tests_dir")
    end
  end

  def test_get_by_name_no_setup_dir
    assert_raise ArgumentError do
      test = SnapshotComparer::Models::TestLocationFactory.get_by_name("unit_test_no_setup_dir")
    end
  end

  def test_get_by_name_no_main_dir
    assert_raise ArgumentError do
      test = SnapshotComparer::Models::TestLocationFactory.get_by_name("unit_test_no_main_dir")
    end
  end

  def test_get_by_name_no_test_file
    assert_raise ArgumentError do
      test = SnapshotComparer::Models::TestLocationFactory.get_by_name("unit_test_no_test_file")
    end
  end

  def test_get_by_name_unknown_test_file
    #assert_raise ArgumentError do
    test = SnapshotComparer::Models::TestLocationFactory.get_by_name("unit_test_unknown_test_file", @sub_app)
    #end
  end
=begin
  def test_get_by_file_location
    test = SnapshotComparer::Models::TestLocationFactory.get_by_file_location("#{@config['home_dir']}/files/apps/unit_test/results/adhoc/current")
    assert_not_nil(test, "Test construction failed.")
    assert_equal("test_custom.jmx",test.href)
    assert_equal(:jmeter,test.type)
    assert_equal("/Users/dimi5963/projects/repose_pt/files/apps/unit_test/results/adhoc/current/meta",test.test_location_dir)
  end

  def test_get_by_file_location_location_dne
    assert_raise ArgumentError do
      test = SnapshotComparer::Models::TestLocationFactory.get_by_file_location("#{@config['home_dir']}/files/apps/unit_test_dne/results/adhoc/current")
    end
  end

  def test_get_by_file_location_no_result_dir
    assert_raise ArgumentError do
      test = SnapshotComparer::Models::TestLocationFactory.get_by_file_location("#{@config['home_dir']}/files/apps/unit_test_no_result_dir/results/adhoc/current")
    end
  end

  def test_get_by_file_location_no_test_type_dir
    assert_raise ArgumentError do
      test = SnapshotComparer::Models::TestLocationFactory.get_by_file_location("#{@config['home_dir']}/files/apps/unit_test_no_result_adhoc_dir/results/adhoc/current")
    end
  end

  def test_get_by_file_location_no_test_instance_dir
    assert_raise ArgumentError do
      test = SnapshotComparer::Models::TestLocationFactory.get_by_file_location("#{@config['home_dir']}/files/apps/unit_test_no_result_current_dir/results/adhoc/current")
    end
  end

  def test_get_by_file_location_no_meta_dir
    assert_raise ArgumentError do
      test = SnapshotComparer::Models::TestLocationFactory.get_by_file_location("#{@config['home_dir']}/files/apps/unit_test_no_config_dir/results/adhoc/current")
    end
  end
  def test_get_by_file_location_no_test_file
    assert_raise ArgumentError do
      test = SnapshotComparer::Models::TestLocationFactory.get_by_file_location("#{@config['home_dir']}/files/apps/unit_test_no_test_file/results/adhoc/current")
    end
  end

  def test_get_by_file_location_unknown_test_file
    assert_raise ArgumentError do
      test = SnapshotComparer::Models::TestLocationFactory.get_by_file_location("#{@config['home_dir']}/files/apps/unit_test_unknown_test_file/results/adhoc/current")
    end
  end
=end
end
