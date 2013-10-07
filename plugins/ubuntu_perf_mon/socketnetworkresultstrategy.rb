require_relative 'abstractstrategy.rb'

class SocketNetworkResultStrategy < AbstractStrategy
  attr_accessor :average_metric_list,:detailed_metric_list 

  def load_metric(name,test_type,id, config_path = nil)
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
    super(name,test_type,id,config_path)
  end 

  def populate_metric(entry, id, start, stop)
    Dir.glob("#{entry}/sysstats.log*").each do |sysstats_file|
      #execute file and get back io results
      io_results = `sar -n SOCK -f #{sysstats_file}`.split(/\r?\n/)
      io_results.each do |result|
        result.scan(/Average:\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)$/).map do |totsck,tcpsck,udpsck,rawsck,ipfrag,tcptw|
          #get device name and then time
          #only use time that's between start and end (in the 24 hour period the time has to be between those 2)
          dev = File.basename(sysstats_file)
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
end
