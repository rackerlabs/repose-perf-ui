require File.expand_path("Models/runner.rb", Dir.pwd)
require File.expand_path("Models/plugin.rb", Dir.pwd)

require 'yaml'

module Apps
  class Bootstrap
    attr_reader :config, :logger
    @@applications ||= []

    def self.logger
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
      logger.level = :debug
      logger
    end

    def self.load_applications
      folder_location = File.expand_path("apps", Dir.pwd)
      Dir.glob("#{folder_location}/**/bootstrap.rb").each do |entry|
        require entry unless File.directory?(entry)
      end
    end

    def self.application_list
      @@applications
    end

    def self.inherited(klass)
      full_path = caller[0].partition(":")[0]
      dir_name =  File.dirname(full_path)[File.dirname(full_path).rindex('/')+1..-1]
      @@applications << {:id => dir_name, :klass => klass}
    end

    def runner_list
      {
 	:jmeter => Models::JMeterRunner.new,
 	:pravega => Models::PravegaRunner.new,
  	:flood => Models::FloodRunner.new,
  	:autobench => Models::AutoBenchRunner.new
      }
    end

    def load_plugins
      raise NotImplementedError, 'Your configuration has not yet been instantiated.  The reason for that is most likely because you are calling load_plugins from Bootstrap itself instead of calling it from an application\'s bootstrap.' unless @config
      plugin_list = @config['application']['plugins']
      plugin_list.each do |key, entry|
        plugin = File.expand_path(entry, Dir.pwd) 
        require plugin unless File.directory?(plugin)
      end
      Plugin.plugin_list 
    end

    def start_test_recording
      raise NotImplementedError, 'Your bootstrap must implement start_test_recording method'
    end

    def stop_test_recording
      raise NotImplementedError, 'Your bootstrap must implement stop_test_recording method'
    end
  end
end
