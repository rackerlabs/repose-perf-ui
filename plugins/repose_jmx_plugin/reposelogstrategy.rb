require_relative 'abstractstrategy.rb'

module ReposeJmxPluginModule
  class ReposeLogStrategy < ReposeJmxPluginModule::AbstractStrategy
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
    end
  end
end