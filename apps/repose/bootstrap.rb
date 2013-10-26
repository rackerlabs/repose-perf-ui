=begin
  This class will have load the following data:
  - plugins for this class
  - name of application
  - description of application
  - methods:
    - start_test
    - finish_test
=end

require 'yaml'
require 'logging'
require File.expand_path("Models/bootstrap.rb", Dir.pwd)

module Apps
  class ReposeBootstrap < Bootstrap
 

    def initialize(logger = nil)
      @logger = logger ? logger : BoostrapRepose.logger
      @config = YAML.load_file(File.expand_path("config/apps/repose.yaml", Dir.pwd))
      @logger.debug "loaded config: #{@config}"  
    end

    def start_test_recording(timestamp = nil)
      start_time = timestamp ? timestamp : Time.now
      #store the start time in Redis
    end

    def stop_test_recording(timestamp = nil)
      end_time = timestamp ? timestamp : Time.now
      #load data for plugins here (from base class)
      plugins = load_plugins
      plugins.each do |plugin|
        plugin.store_data(start_time,end_time)
      end 
    end
  end
end
