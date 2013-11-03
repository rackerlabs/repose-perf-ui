require 'simplecov'

SimpleCov.start

require "test/unit"
require_relative "../apps/bootstrap.rb"

class BootstrapTest < Test::Unit::TestCase
  def setup
    File.open(File.expand_path("config/apps/repose.yaml",Dir.pwd), "w") do |f|
      f << "application:\n"
      f << "  name: Repose\n"
      f << "  location: apps/repose/bootstrap.rb\n"
      f << "  plugins:\n"
      f << "    location: plugins/ubuntu_perf_mon/plugin.rb\n"
      f << "    location: plugins/repose_jmx_plugin/plugin.rb\n"
    end
    test_contents = File.read(File.expand_path("tests/config_test.yaml",Dir.pwd))
    File.open(File.expand_path("config/config.yaml",Dir.pwd), "w") do |f|
      f << test_contents
    end
  end

  def teardown
    Redis.new(Apps::Bootstrap.backend_connect).del("repose:test:1:start")
    File.delete(File.expand_path("config/apps/repose.yaml",Dir.pwd))
    File.delete(File.expand_path("config/config.yaml",Dir.pwd))
  end
  def test_initialize
    Apps::Bootstrap.load_applications
    assert_not_nil(Apps::Bootstrap.application_list)
    assert(Apps::Bootstrap.application_list.find {|a| a[:klass].to_s == "Apps::ReposeBootstrap"})
  end

  def test_application_list_retrieval
    Apps::Bootstrap.load_applications
    assert_not_nil(Apps::Bootstrap.application_list)
    assert(Apps::Bootstrap.application_list.find {|a| a[:id] == 'repose'}[:klass].to_s == "Apps::ReposeBootstrap")
  end

  def test_runner_list
    runner_list = Apps::Bootstrap.runner_list
    assert_not_nil(runner_list)
    assert(runner_list.has_key?(:jmeter))
  end

  def test_logger
    assert_not_nil(Apps::Bootstrap.logger)
    assert_equal(0, Apps::Bootstrap.logger.level)
  end

  def test_start_record_on_repose
    Apps::Bootstrap.load_applications
    assert_not_nil(Apps::Bootstrap.application_list)
    repose_bootstrap = Apps::Bootstrap.application_list.find {|a| a[:id] == 'repose'}[:klass]
    response = repose_bootstrap.new.start_test_recording(1)
    assert_equal("OK", response[:response])
    assert_in_delta(Time.now.to_i, response[:time].to_i, 10)
  end

  def test_start_record_on_repose_with_time
    Apps::Bootstrap.load_applications
    assert_not_nil(Apps::Bootstrap.application_list)
    repose_bootstrap = Apps::Bootstrap.application_list.find {|a| a[:id] == 'repose'}[:klass]
    timestamp = Time.now + 1000 
    response = repose_bootstrap.new.start_test_recording(1, timestamp)
    assert_equal("OK", response[:response])
    assert_equal(timestamp, response[:time])
  end

  def test_stop_record_on_repose
    Apps::Bootstrap.load_applications
    assert_not_nil(Apps::Bootstrap.application_list)
    repose_bootstrap = Apps::Bootstrap.application_list.find {|a| a[:id] == 'repose'}[:klass]
    repose_bootstrap.new.start_test_recording(1)
    response = repose_bootstrap.new.stop_test_recording(1)
    assert_equal("OK", response)
  end

  def test_stop_record_on_repose_with_time
    Apps::Bootstrap.load_applications
    assert_not_nil(Apps::Bootstrap.application_list)
    repose_bootstrap = Apps::Bootstrap.application_list.find {|a| a[:id] == 'repose'}[:klass]
    repose_bootstrap.new.start_test_recording(1)
    timestamp = Time.now + 1000
    response = repose_bootstrap.new.stop_test_recording(1, timestamp)
    assert_equal("OK", response)
  end
  
  def test_stop_record_without_start
    Apps::Bootstrap.load_applications
    assert_not_nil(Apps::Bootstrap.application_list)
    repose_bootstrap = Apps::Bootstrap.application_list.find {|a| a[:id] == 'repose'}[:klass]
    assert_raise ArgumentError do
      response = repose_bootstrap.new.stop_test_recording(1)
    end
  end

  def test_backend_connect_default
    database = Apps::Bootstrap.backend_connect
    assert_not_nil(database)
    assert_equal('50.56.175.34', database[:host])
    assert_equal(6379, database[:port])
    assert_equal(1, database[:db])
  end
  
  def test_backend_connect_with_test
    database = Apps::Bootstrap.backend_connect({:host => 'localhost'})
    assert_not_nil(database)
    assert_equal('localhost', database[:host])
    assert_equal(6379, database[:port])
    assert_equal(1, database[:db])
  end
  
  def test_backend_connect_with_test_and_port
    database = Apps::Bootstrap.backend_connect({:host => 'localhost', :port => 80})
    assert_not_nil(database)
    assert_equal('localhost', database[:host])
    assert_equal(80, database[:port])
    assert_equal(1, database[:db])
  end
  
  def test_backend_connect_with_test_and_db
    database = Apps::Bootstrap.backend_connect({:host => 'localhost', :port => 80, :db => 2})
    assert_not_nil(database)
    assert_equal('localhost', database[:host])
    assert_equal(80, database[:port])
    assert_equal(2, database[:db])
  end
  
  def test_backend_connect_no_host
    assert_raise ArgumentError do
      database = Apps::Bootstrap.backend_connect({:port => 80, :db => 2})
    end
  end
  
  def test_config_load_from_repose
  end

  def test_load_plugins_from_parent
    assert_raise NotImplementedError do
      Apps::Bootstrap.new.load_plugins
    end
  end

  def test_load_plugins_from_repose
  end
end

