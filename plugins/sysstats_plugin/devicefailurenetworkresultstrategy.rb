require_relative 'abstractstrategy.rb'

module SysstatsPluginModule
  class DeviceFailureNetworkResultStrategy < AbstractStrategy
    attr_accessor :average_metric_list,:detailed_metric_list 
  
    def self.metric_description
      {
        "rxerr/s" => "Total number of bad packets received per second.",
        "txerr/s" => "Total number of errors that happened per second while transmitting packets.",
        "coll/s" => "Number of collisions that happened per second while transmitting packets.",
        "rxdrop/s" => "Number of received packets dropped per second because of a lack of space in linux buffers.",
        "txdrop/s" => "Number of transmitted packets dropped per second because of a lack of space in linux buffers.",
        "txcarr/s" => "Number of carrier-errors that happened per second while transmitting packets.",
        "rxfifo/s" => "Number of FIFO overrun errors that happened per second on received packets.",
        "txfifo/s" => "Number of FIFO overrun errors that happened per second on transmitted packets.",
        "rxfram/s" => "Number of frame alignment errors that happened per second on received packets."
      }
    end
  
    def initialize(db, fs_ip, application, name, test_type, id, metric_id)
      @average_metric_list = {
        "rxerr/s" => [],
        "txerr/s" => [],
        "coll/s" => [],
        "rxdrop/s" => [],
        "txdrop/s" => [],
        "txcarr/s" => [],
        "rxfifo/s" => [],
        "txfifo/s" => [],
        "rxfram/s" => []
      }
  
      @detailed_metric_list = {
        "rxerr/s" => [],
        "txerr/s" => [],
        "coll/s" => [],
        "rxdrop/s" => [],
        "txdrop/s" => [],
        "txcarr/s" => [],
        "rxfifo/s" => [],
        "txfifo/s" => [],
        "rxfram/s" => []
      }
      super(db, fs_ip, application, name, test_type, id, metric_id)
    end 
  
    def populate_metric(entry, name, id, start, stop)
      open(entry).readlines.each do |result|
        result.scan(/Average:\s+(\S+)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)$/).map do |iface,rxerrs,txerrs,colls,rxdrops,txdrops,txcarrs,rxframs,rxfifos,txfifos|
          #get device name and then time
          #only use time that's between start and end (in the 24 hour period the time has to be between those 2)
          dev = "#{File.basename(entry)}-#{iface}"
          initialize_metric(@average_metric_list,"rxerr/s",dev)
          @average_metric_list["rxerr/s"].find {|key_data| key_data[:dev_name] == dev}[:results] = rxerrs
          initialize_metric(@average_metric_list,"txerr/s",dev)
          @average_metric_list["txerr/s"].find {|key_data| key_data[:dev_name] == dev}[:results] = txerrs
          initialize_metric(@average_metric_list,"coll/s",dev)
          @average_metric_list["coll/s"].find {|key_data| key_data[:dev_name] == dev}[:results] = colls
          initialize_metric(@average_metric_list,"rxdrop/s",dev)
          @average_metric_list["rxdrop/s"].find {|key_data| key_data[:dev_name] == dev}[:results] = rxdrops
          initialize_metric(@average_metric_list,"txdrop/s",dev)
          @average_metric_list["txdrop/s"].find {|key_data| key_data[:dev_name] == dev}[:results] = txdrops
          initialize_metric(@average_metric_list,"txcarr/s",dev)
          @average_metric_list["txcarr/s"].find {|key_data| key_data[:dev_name] == dev}[:results] = txcarrs
          initialize_metric(@average_metric_list,"rxfram/s",dev)
          @average_metric_list["rxfram/s"].find {|key_data| key_data[:dev_name] == dev}[:results] = rxframs
          initialize_metric(@average_metric_list,"rxfifo/s",dev)
          @average_metric_list["rxfifo/s"].find {|key_data| key_data[:dev_name] == dev}[:results] = rxfifos
          initialize_metric(@average_metric_list,"txfifo/s",dev)
          @average_metric_list["txfifo/s"].find {|key_data| key_data[:dev_name] == dev}[:results] = txfifos
        end
        result.scan(/(\d+:\d+:\d+ \S+)\s+(\S+)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)$/).map do |time,iface,rxerrs,txerrs,colls,rxdrops,txdrops,txcarrs,rxframs,rxfifos,txfifos|
          dev = "#{File.basename(entry)}-#{iface}"
          initialize_metric(@detailed_metric_list,"rxerr/s",dev)
          @detailed_metric_list["rxerr/s"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value => rxerrs}
          initialize_metric(@detailed_metric_list,"txerr/s",dev)
          @detailed_metric_list["txerr/s"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value =>  txerrs}
          initialize_metric(@detailed_metric_list,"coll/s",dev)
          @detailed_metric_list["coll/s"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value =>  colls}
          initialize_metric(@detailed_metric_list,"rxdrop/s",dev)
          @detailed_metric_list["rxdrop/s"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value =>  rxdrops}
          initialize_metric(@detailed_metric_list,"txdrop/s",dev)
          @detailed_metric_list["txdrop/s"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value =>  txdrops}
          initialize_metric(@detailed_metric_list,"txcarr/s",dev)
          @detailed_metric_list["txcarr/s"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value =>  txcarrs}
          initialize_metric(@detailed_metric_list,"rxfram/s",dev)
          @detailed_metric_list["rxfram/s"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value =>  rxframs}
          initialize_metric(@detailed_metric_list,"rxfifo/s",dev)
          @detailed_metric_list["rxfifo/s"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value =>  rxfifos}
          initialize_metric(@detailed_metric_list,"txfifo/s",dev)
          @detailed_metric_list["txfifo/s"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value =>  txfifos}
        end
      end
    end
  end
end