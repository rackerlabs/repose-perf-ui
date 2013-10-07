require_relative 'models.rb'
require_relative 'runner.rb'
require_relative 'plugin.rb'

require 'yaml'

module Models
  class Bootstrap
    include ResultModule
		
    def runner_list
      {
 	:jmeter => Models::JMeterRunner.new,
 	:pravega => Models::PravegaRunner.new,
  	:flood => Models::FloodRunner.new,
  	:autobench => Models::AutoBenchRunner.new
      }
    end

    def load_plugins
      folder_location = "#{config['home_dir']}/plugins"
      Dir.glob("#{folder_location}/**/plugin.rb").each do |entry| 
        require entry unless File.directory?(entry)
      end
      Plugin.plugin_list 
    end
  end
end
