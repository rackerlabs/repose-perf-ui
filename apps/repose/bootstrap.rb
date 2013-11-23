require 'yaml'
require 'logging'
require 'redis'
require File.expand_path("apps/bootstrap.rb", Dir.pwd)

module Apps
  class ReposeBootstrap < Bootstrap
 

    def initialize(environment = :production, redis_info = nil, logger = nil)
      if environment == :production
        @config = YAML.load_file(File.expand_path("config/apps/repose.yaml", Dir.pwd))
      elsif environment == :test
        @config = YAML.load_file(File.expand_path("config/apps/test_repose.yaml", Dir.pwd))
      elsif environment == :development
        @config = YAML.load_file(File.expand_path("config/apps/dev_repose.yaml", Dir.pwd))
      end
      super(redis_info, logger)      
    end

    def start_test_recording(id, sub_app = 'main', type = 'load', timestamp = nil)
      super("repose:test:#{id}:#{sub_app}:#{type}:start", timestamp)
    end

    def stop_test_recording(id, sub_app = 'main', type = 'load', timestamp = nil)
      super("repose:test:#{id}:#{sub_app}:#{type}:start", timestamp)
    end
  end
end
