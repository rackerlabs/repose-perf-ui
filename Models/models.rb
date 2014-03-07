require 'logging'
require_relative 'test.rb'
require_relative 'configuration.rb'
require_relative 'testlocation.rb'
require_relative 'results.rb'
require_relative 'environment.rb'

module SnapshotComparer
  module Models
    def config(file_path = nil, logger = nil)
      logger.debug "file path: #{file_path}" if logger
      if file_path && File.exists?(file_path)
  		  YAML.load_file(file_path)
      	logger.debug "loaded file path" if logger
      else
      	logger.debug "load the following: #{File.expand_path("config/config.yaml", Dir.pwd)}" if logger
        YAML.load_file(File.expand_path("config/config.yaml", Dir.pwd))
      end
    end
  end
end
