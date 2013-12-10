require_relative 'abstractstrategy.rb'

module SysstatsPluginModule
  class TcpNetworkResultStrategy < AbstractStrategy
    attr_accessor :average_metric_list,:detailed_metric_list 
  
    def self.metric_description
      {
        "active/s" => "The number of times TCP connections have made a direct transition to the SYN-SENT state from the CLOSED state per second [tcpActiveOpens].",
        "passive/s" => "The number of times TCP connections have made a direct transition to the SYN-RCVD state from the LISTEN state per second [tcpPassiveOpens].",
        "iseg/s" => "The total number of segments received per second, including those received in error [tcpInSegs].  This count includes segments received on currently established connections.",
        "oseg/s" => "The total number of segments sent per second, including those on current connections but excluding those containing only retransmitted octets [tcpOutSegs]."
      }
    end
  
    def initialize(db, fs_ip, application, name, test_type, id, metric_id)
      @average_metric_list = {
        "active/s" => [],
        "passive/s" => [],
        "iseg/s" => [],
        "oseg/s" => []
      }
  
      @detailed_metric_list = {
        "active/s" => [],
        "passive/s" => [],
        "iseg/s" => [],
        "oseg/s" => []
      }
      super(db, fs_ip, application, name, test_type, id, metric_id)
    end 
  
    def populate_metric(entry, name, id, start, stop)
      open(entry).readlines.each do |result|
        result.scan(/Average:\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)$/).map do |actives, passives, isegs, osegs|
          #get device name and then time
          #only use time that's between start and end (in the 24 hour period the time has to be between those 2)
          dev = File.basename(entry)
          initialize_metric(@average_metric_list,"active/s",dev)
          @average_metric_list["active/s"].find {|key_data| key_data[:dev_name] == dev}[:results] = actives
          initialize_metric(@average_metric_list,"passive/s",dev)
          @average_metric_list["passive/s"].find {|key_data| key_data[:dev_name] == dev}[:results] = passives
          initialize_metric(@average_metric_list,"iseg/s",dev)
          @average_metric_list["iseg/s"].find {|key_data| key_data[:dev_name] == dev}[:results] = isegs
          initialize_metric(@average_metric_list,"oseg/s",dev)
          @average_metric_list["oseg/s"].find {|key_data| key_data[:dev_name] == dev}[:results] = osegs
        end
        result.scan(/(\d+:\d+:\d+ \S+)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)$/).map do |time,actives, passives, isegs, osegs|
          #get device name and then time
          #only use time that's between start and end (in the 24 hour period the time has to be between those 2)
          dev = File.basename(entry)
          initialize_metric(@detailed_metric_list,"active/s",dev)
          @detailed_metric_list["active/s"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value => actives}
          initialize_metric(@detailed_metric_list,"passive/s",dev)
          @detailed_metric_list["passive/s"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value => passives}
          initialize_metric(@detailed_metric_list,"iseg/s",dev)
          @detailed_metric_list["iseg/s"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value => isegs}
          initialize_metric(@detailed_metric_list,"oseg/s",dev)
          @detailed_metric_list["oseg/s"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value => osegs}
        end
      end
    end
  end
end