require_relative 'abstractstrategy.rb'

class SocketNetworkResultStrategy < AbstractStrategy
  attr_accessor :average_metric_list,:detailed_metric_list 

  def self.metric_description
    {
      "totsck" => "",
      "tcpsck" => "",
      "udpsck" => "",
      "rawsck" => "",
      "ip-frag" => "",
      "tcp-tw" => ""
    }
  end

  def initialize(db, fs_ip, application, name, test_type, id)
    @average_metric_list = {
      "totsck" => [],
      "tcpsck" => [],
      "udpsck" => [],
      "rawsck" => [],
      "ip-frag" => [],
      "tcp-tw" => []
    }

    @detailed_metric_list = {
      "totsck" => [],
      "tcpsck" => [],
      "udpsck" => [],
      "rawsck" => [],
      "ip-frag" => [],
      "tcp-tw" => []
    }
    super(db, fs_ip, application, name, test_type, id)
  end 

  def populate_metric(entry, name, id, start, stop)
    open(entry).readlines.each do |result|
      result.scan(/Average:\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)$/).map do |totsck,tcpsck,udpsck,rawsck,ipfrag,tcptw|
        #get device name and then time
        #only use time that's between start and end (in the 24 hour period the time has to be between those 2)
        dev = File.basename(entry)
        initialize_metric(@average_metric_list,"totsck",dev)
        @average_metric_list["totsck"].find {|key_data| key_data[:dev_name] == dev}[:results] = totsck
        initialize_metric(@average_metric_list,"tcpsck",dev)
        @average_metric_list["tcpsck"].find {|key_data| key_data[:dev_name] == dev}[:results] = tcpsck
        initialize_metric(@average_metric_list,"udpsck",dev)
        @average_metric_list["udpsck"].find {|key_data| key_data[:dev_name] == dev}[:results] = udpsck
        initialize_metric(@average_metric_list,"rawsck",dev)
        @average_metric_list["rawsck"].find {|key_data| key_data[:dev_name] == dev}[:results] = rawsck
        initialize_metric(@average_metric_list,"ip-frag",dev)
        @average_metric_list["ip-frag"].find {|key_data| key_data[:dev_name] == dev}[:results] = ipfrag
        initialize_metric(@average_metric_list,"tcp-tw",dev)
        @average_metric_list["tcp-tw"].find {|key_data| key_data[:dev_name] == dev}[:results] = tcptw
      end
    end
  end
end
