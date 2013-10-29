require "test/unit"
require_relative "../apps/bootstrap.rb"

class BootstrapTest < Test::Unit::TestCase
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
    repose_bootstrap.new.start_recording
  end

  def test_stop_record_on_repose
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

