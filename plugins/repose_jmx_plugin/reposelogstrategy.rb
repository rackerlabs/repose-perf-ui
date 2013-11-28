require_relative 'abstractstrategy.rb'

class ReposeLogStrategy < ReposeAbstractStrategy
attr_accessor :average_metric_list,:detailed_metric_list 
  def initialize(db, fs_ip, application, name, test_type, id)
    @average_metric_list = {}

    @detailed_metric_list = {}
    super(db, fs_ip, application, name, test_type, id)
  end 

  def populate_metric(entry, name, id, start, stop)
  end
end
