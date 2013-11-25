require 'yaml'
require 'logging'
require 'redis'
require File.expand_path("apps/bootstrap.rb", Dir.pwd)

module Apps
  class ComparisonAppBootstrap < Bootstrap
 

    def initialize(environment = :production, redis_info = nil, logger = nil)
      if environment == :production
        @config = YAML.load_file(File.expand_path("config/apps/comparison_app.yaml", Dir.pwd))
      elsif environment == :test
        @config = YAML.load_file(File.expand_path("config/apps/test_comparison_app.yaml", Dir.pwd))
      elsif environment == :development
        @config = YAML.load_file(File.expand_path("config/apps/dev_comparison_app.yaml", Dir.pwd))
      end

      super(redis_info, logger)      
    end

    def start_test_recording(id, timestamp = nil)
      super("comparison_app:test:#{id}:start", timestamp)
    end

    def stop_test_recording(id, timestamp = nil)
      super("comparison_app:test:#{id}:start", timestamp)
    end
  end
end
