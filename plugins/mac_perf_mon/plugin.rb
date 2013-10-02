require 'yaml'

class Plugin
  def initialize(file_path=nil, logger=nil)
    logger.debug "file path: #{file_path}" if logger
    if file_path && File.exists?(file_path)
      YAML.load_file(file_path) 
    else
      logger.debug "load the following: #{File.expand_path("../../../plugins/mac_perfmon.yaml", __FILE__)}" if logger
      YAML.load_file(File.expand_path("../../../config/plugins/mac_perfmon.yaml", __FILE__))
    end
  end

=begin
	parse data will be called on every collection to load data from 
=end
  def parse_data
  end

=begin
  	show only summary data (average, min, max, 90%)
=end
  def show_summary_data
  end

=begin
	show all data and return in a list of hashes
=end
  def show_detailed_data
  end
end