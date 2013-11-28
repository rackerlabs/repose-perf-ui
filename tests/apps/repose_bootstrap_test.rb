require "test/unit"
require_relative "../../apps/repose/bootstrap.rb"

class ReposeBootstrapTest < Test::Unit::TestCase
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
    repose = Apps::ReposeBootstrap.new
    assert_not_nil(repose.logger)
    assert_not_nil(repose.config)
    assert(repose.logger.level == 0)
    assert(repose.logger.info?)
    assert(repose.logger.debug?)
    assert_equal("Repose",repose.config["application"]["name"])
  end

  def test_initialize_with_logging_info
    Logging.color_scheme( 'bright',
      :levels => {
        :info  => :green,
        :warn  => :yellow,
        :error => :red,
        :fatal => [:white, :on_red]
      },
      :date => :blue,
      :logger => :cyan,
      :message => :magenta
    )
    logger = Logging.logger(STDOUT)
    logger.level = :info
    repose = Apps::ReposeBootstrap.new(logger)
    assert_not_nil(repose.logger)
    assert_not_nil(repose.config)
    assert(repose.logger.level == 1)
    assert(repose.logger.info?)
    assert(!repose.logger.debug?)
    assert_equal("Repose",repose.config["application"]["name"])
  end
end
