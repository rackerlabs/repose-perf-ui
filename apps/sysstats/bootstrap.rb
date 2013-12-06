require 'yaml'
require 'logging'
require 'redis'
require File.expand_path("apps/bootstrap.rb", Dir.pwd)

module Apps
  class SysstatsBootstrap < Bootstrap
 

    def initialize(environment = :production, redis_info = nil, logger = nil)
      if environment == :production
        @config = YAML.load_file(File.expand_path("config/apps/sysstats.yaml", Dir.pwd))
      elsif environment == :test
        @config = YAML.load_file(File.expand_path("config/apps/test_sysstats.yaml", Dir.pwd))
      elsif environment == :development
        @config = YAML.load_file(File.expand_path("config/apps/dev_sysstats.yaml", Dir.pwd))
      end
      super(redis_info, logger)      
    end
  end
end
