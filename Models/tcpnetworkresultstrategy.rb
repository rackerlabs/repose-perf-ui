require_relative 'result.rb'

class TcpNetworkResultStrategy < AbstractStrategy
  attr_accessor :average_metric_list,:detailed_metric_list 
  def initialize(name,test_type,id, config_path = nil)
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
    super(name,test_type,id,config_path)
  end 

  def populate_metric(entry, id, start, stop)
    Dir.glob("#{entry}/sysstats.log*").each do |sysstats_file|
      #execute file and get back io results
      p "sar -d -f #{sysstats_file}"
      io_results = `sar -n TCP -f #{sysstats_file}`.split(/\r?\n/)
      io_results.each do |result|
        result.scan(/Average:\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)$/).map do |actives, passives, isegs, osegs|
          #get device name and then time
          #only use time that's between start and end (in the 24 hour period the time has to be between those 2)
          dev = File.basename(sysstats_file)
          initialize_metric(@average_metric_list,"active/s",dev)
          @average_metric_list["active/s"].find {|key_data| key_data[:dev_name] == dev}[:results] = actives
          initialize_metric(@average_metric_list,"passive/s",dev)
          @average_metric_list["passive/s"].find {|key_data| key_data[:dev_name] == dev}[:results] = passives
          initialize_metric(@average_metric_list,"iseg/s",dev)
          @average_metric_list["iseg/s"].find {|key_data| key_data[:dev_name] == dev}[:results] = isegs
          initialize_metric(@average_metric_list,"oseg/s",dev)
          @average_metric_list["oseg/s"].find {|key_data| key_data[:dev_name] == dev}[:results] = osegs
        end
      end
    end
  end
end
