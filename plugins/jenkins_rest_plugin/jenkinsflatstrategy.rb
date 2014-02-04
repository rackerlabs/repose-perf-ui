require_relative 'abstractstrategy.rb'

module JenkinsRestPluginModule
  class JenkinsFlatStrategy < JenkinsRestPluginModule::AbstractStrategy
  
    attr_accessor :average_metric_list,:detailed_metric_list 
    
    def self.metric_description
      {
      }
    end
  
    def initialize(db, fs_ip, application, name, test_type, id, metric_id)
      @average_metric_list = {}
  
      @detailed_metric_list = {}
      super(db, fs_ip, application, name, test_type, id, metric_id)
    end 
  
    def populate_metric(entry, name, id, start, stop)
      output = open(entry).read
      results = JSON.parse(output) if output
      @average_metric_list = results
    end
  end
end