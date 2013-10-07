require_relative 'abstractstrategy.rb'

class DeviceNetworkResultStrategy < AbstractStrategy
  attr_accessor :average_metric_list,:detailed_metric_list 

  def initialize(name,test_type,id, config_path = nil)
    @average_metric_list = {
      "rxpck/s" => [],
      "txpck/s" => [],
      "rxkB/s" => [],
      "txkB/s" => [],
      "rxcmp/s" => [],
      "txcmp/s" => [],
      "rxmcst/s" => []
    }

    @detailed_metric_list = {
      "rxpck/s" => [],
      "txpck/s" => [],
      "rxkB/s" => [],
      "txkB/s" => [],
      "rxcmp/s" => [],
      "txcmp/s" => [],
      "rxmcst/s" => []
    }
    super(name,test_type,id,config_path)
  end 

  def populate_metric(entry, id, start, stop)
    Dir.glob("#{entry}/sysstats.log*").each do |sysstats_file|
      #execute file and get back io results
      io_results = `sar -n DEV -f #{sysstats_file}`.split(/\r?\n/)
      io_results.each do |result|
        result.scan(/Average:\s+(\S+)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)$/).map do |iface,rxpcks,txpcks,rxkbs,txkbs,rxcmps,txcmps,rxmcsts|
          #get device name and then time
          #only use time that's between start and end (in the 24 hour period the time has to be between those 2)
          dev = "#{File.basename(sysstats_file)}-#{iface}"
          initialize_metric(@average_metric_list,"rxpck/s",dev)
          @average_metric_list["rxpck/s"].find {|key_data| key_data[:dev_name] == dev}[:results] = rxpcks
          initialize_metric(@average_metric_list,"txpck/s",dev)
          @average_metric_list["txpck/s"].find {|key_data| key_data[:dev_name] == dev}[:results] = txpcks
          initialize_metric(@average_metric_list,"rxkB/s",dev)
          @average_metric_list["rxkB/s"].find {|key_data| key_data[:dev_name] == dev}[:results] = rxkbs
          initialize_metric(@average_metric_list,"txkB/s",dev)
          @average_metric_list["txkB/s"].find {|key_data| key_data[:dev_name] == dev}[:results] = txkbs
          initialize_metric(@average_metric_list,"rxcmp/s",dev)
          @average_metric_list["rxcmp/s"].find {|key_data| key_data[:dev_name] == dev}[:results] = rxcmps
          initialize_metric(@average_metric_list,"txcmp/s",dev)
          @average_metric_list["txcmp/s"].find {|key_data| key_data[:dev_name] == dev}[:results] = txcmps
          initialize_metric(@average_metric_list,"rxmcst/s",dev)
          @average_metric_list["rxmcst/s"].find {|key_data| key_data[:dev_name] == dev}[:results] = rxmcsts
        end
        result.scan(/(\d+:\d+:\d+ \S+)\s+(\S+)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)$/).map do |time,iface,rxpcks,txpcks,rxkbs,txkbs,rxcmps,txcmps,rxmcsts|
          #get device name and then time
          #only use time that's between start and end (in the 24 hour period the time has to be between those 2)
          dev = "#{File.basename(sysstats_file)}-#{iface}"
          initialize_metric(@average_metric_list,"rxpck/s",dev)
          @average_metric_list["rxpck/s"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value => rxpcks}
          initialize_metric(@detailed_metric_list,"txpck/s",dev)
          @detailed_metric_list["txpck/s"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value => txpcks}
          initialize_metric(@detailed_metric_list,"rxkB/s",dev)
          @detailed_metric_list["rxkB/s"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value => rxkbs}
          initialize_metric(@detailed_metric_list,"txkB/s",dev)
          @detailed_metric_list["txkB/s"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value => txkbs}
          initialize_metric(@detailed_metric_list,"rxcmp/s",dev)
          @detailed_metric_list["rxcmp/s"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value => rxcmps}
          initialize_metric(@detailed_metric_list,"txcmp/s",dev)
          @detailed_metric_list["txcmp/s"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value => txcmps}
          initialize_metric(@detailed_metric_list,"rxmcst/s",dev)
          @detailed_metric_list["rxmcst/s"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value => rxmcsts}
        end
      end
    end
  end
end
