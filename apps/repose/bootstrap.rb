require 'yaml'
require 'logging'
require 'redis'
require File.expand_path("apps/bootstrap.rb", Dir.pwd)

module Apps
  class ReposeBootstrap < Bootstrap
 

    def initialize(redis_info = nil, logger = nil)
      @logger = logger ? logger : Bootstrap.logger
      @config = YAML.load_file(File.expand_path("config/apps/repose.yaml", Dir.pwd))
      @logger.debug "loaded config: #{@config}"  
      if redis_info
        raise ArgumentError, "required information missing from your storage connection." unless redis_info.has_key?(:host)
      end
      @db = Bootstrap.backend_connect(redis_info)
      @logger.debug "loaded backend: #{@db.inspect}"
      
    end

    def start_test_recording(id, sub_app = 'main', type = 'load', timestamp = nil)
      super("repose:test:#{id}:#{sub_app}:#{type}:start", timestamp)
    end

    def stop_test_recording(id, sub_app = 'main', type = 'load', timestamp = nil)
      super("repose:test:#{id}:#{sub_app}:#{type}:start", timestamp)
    end
  end
end
