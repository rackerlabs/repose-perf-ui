require 'yaml'
require 'logging'
require 'redis'
require File.expand_path("apps/bootstrap.rb", Dir.pwd)

module SnapshotComparer
module Apps
  class ReposeComparisonAppBootstrap < Bootstrap


    def initialize(environment = :production, redis_info = nil, logger = nil)
      if environment == :production
        @config = YAML.load_file(File.expand_path("config/apps/repose_comparison_app.yaml", Dir.pwd))
      elsif environment == :test
        @config = YAML.load_file(File.expand_path("config/apps/test_repose_comparison_app.yaml", Dir.pwd))
      elsif environment == :development
        @config = YAML.load_file(File.expand_path("config/apps/dev_repose_comparison_app.yaml", Dir.pwd))
      end

      super(redis_info, logger)
    end
  end
end
end
