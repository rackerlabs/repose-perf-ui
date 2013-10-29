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
  end

  def teardown
    File.delete(File.expand_path("config/apps/repose.yaml",Dir.pwd))
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
  end

  def test_logger
  end

  def test_start_record_on_repose
    Apps::Bootstrap.load_applications
    assert_not_nil(Apps::Bootstrap.application_list)
    repose_bootstrap = Apps::Bootstrap.application_list.find {|a| a[:id] == 'repose'}[:klass]
    timestamp = repose_bootstrap.new.start_test_recording
    assert_equal(timestamp.to_i, Time.now.to_i)
  end

  def test_start_record_on_repose_with_time
    Apps::Bootstrap.load_applications
    assert_not_nil(Apps::Bootstrap.application_list)
    repose_bootstrap = Apps::Bootstrap.application_list.find {|a| a[:id] == 'repose'}[:klass]
    timestamp = Time.now + 1000 
    start_timestamp = repose_bootstrap.new.start_test_recording(timestamp)
    assert_equal(start_timestamp, timestamp)
  end

  def test_stop_record_on_repose
    Apps::Bootstrap.load_applications
    assert_not_nil(Apps::Bootstrap.application_list)
    repose_bootstrap = Apps::Bootstrap.application_list.find {|a| a[:id] == 'repose'}[:klass]
    timestamp = repose_bootstrap.new.stop_test_recording
    assert_equal(timestamp.to_i, Time.now.to_i)
  end

  def test_stop_record_on_repose_with_time
    Apps::Bootstrap.load_applications
    assert_not_nil(Apps::Bootstrap.application_list)
    repose_bootstrap = Apps::Bootstrap.application_list.find {|a| a[:id] == 'repose'}[:klass]
    timestamp = Time.now + 1000 
    stop_timestamp = repose_bootstrap.new.stop_test_recording(timestamp)
    assert_equal(stop_timestamp, timestamp)
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

