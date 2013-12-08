require_relative 'abstractstrategy.rb'

module SysstatsPluginModule
  class TcpFailureNetworkResultStrategy < AbstractStrategy
    attr_accessor :average_metric_list,:detailed_metric_list 
  
    def self.metric_description
      {
        "atmptf/s" => "",
        "estres/s" => "",
        "retrans/s" => "",
        "isegerr/s" => "",
        "orsts/s" => ""
      }
    end
  
    def initialize(db, fs_ip, application, name, test_type, id)
      @average_metric_list = {
        "atmptf/s" => [],
        "estres/s" => [],
        "retrans/s" => [],
        "isegerr/s" => [],
        "orsts/s" => []
      }
  
      @detailed_metric_list = {
        "atmptf/s" => [],
        "estres/s" => [],
        "retrans/s" => [],
        "isegerr/s" => [],
        "orsts/s" => []
      }
      super(db, fs_ip, application, name, test_type, id)
    end 
  
    def populate_metric(entry, name, id, start, stop)
      open(entry).readlines.each do |result|
        result.scan(/Average:\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)$/).map do |atmptfs,estress,retranss,isegerrs,orstss|
          #get device name and then time
          #only use time that's between start and end (in the 24 hour period the time has to be between those 2)
          dev = File.basename(entry)
          initialize_metric(@average_metric_list,"atmptf/s",dev)
          @average_metric_list["atmptf/s"].find {|key_data| key_data[:dev_name] == dev}[:results] = atmptfs
          initialize_metric(@average_metric_list,"estres/s",dev)
          @average_metric_list["estres/s"].find {|key_data| key_data[:dev_name] == dev}[:results] = estress
          initialize_metric(@average_metric_list,"retrans/s",dev)
          @average_metric_list["retrans/s"].find {|key_data| key_data[:dev_name] == dev}[:results] = retranss
          initialize_metric(@average_metric_list,"isegerr/s",dev)
          @average_metric_list["isegerr/s"].find {|key_data| key_data[:dev_name] == dev}[:results] = isegerrs
          initialize_metric(@average_metric_list,"orsts/s",dev)
          @average_metric_list["orsts/s"].find {|key_data| key_data[:dev_name] == dev}[:results] = orstss
        end
        result.scan(/(\d+:\d+:\d+ \S+)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)$/).map do |time,atmptfs,estress,retranss,isegerrs,orstss|
          #get device name and then time
          #only use time that's between start and end (in the 24 hour period the time has to be between those 2)
          dev = File.basename(entry)
          initialize_metric(@detailed_metric_list,"atmptf/s",dev)
          @detailed_metric_list["atmptf/s"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value => atmptfs}
          initialize_metric(@detailed_metric_list,"estres/s",dev)
          @detailed_metric_list["estres/s"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value => estress}
          initialize_metric(@detailed_metric_list,"retrans/s",dev)
          @detailed_metric_list["retrans/s"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value => retranss}
          initialize_metric(@detailed_metric_list,"isegerr/s",dev)
          @detailed_metric_list["isegerr/s"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value => isegerrs}
          initialize_metric(@detailed_metric_list,"orsts/s",dev)
          @detailed_metric_list["orsts/s"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value => orstss}
        end
      end
    end
  end
end