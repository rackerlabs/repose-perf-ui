require_relative 'abstractstrategy.rb'

class IOTransferResultStrategy < AbstractStrategy
  attr_accessor :average_metric_list,:detailed_metric_list 

  def self.metric_description
    {
      "tps" => "",
      "rtps" => "",
      "wtps" => "",
      "bread/s" => "",
      "bwrtn/s" => ""
    }
  end

  def initialize(db, fs_ip, application, name, test_type, id)
    @average_metric_list = {
      "tps" => [],
      "rtps" => [],
      "wtps" => [],
      "bread/s" => [],
      "bwrtn/s" => []
    }

    @detailed_metric_list = {
      "tps" => [],
      "rtps" => [],
      "wtps" => [],
      "bread/s" => [],
      "bwrtn/s" => []
    }
    super(db, fs_ip, application, name, test_type, id)
  end 

  def populate_metric(entry, name, id, start, stop)
    open(entry).readlines.each do |result|
      result.scan(/Average:\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)/).map do |tps,rtps,wtps,breads,bwrtns|
        #get device name and then time
        dev = File.basename(entry)
        #only use time that's between start and end (in the 24 hour period the time has to be between those 2)
        initialize_metric(@average_metric_list,"tps",dev)
        @average_metric_list["tps"].find {|key_data| key_data[:dev_name] == dev}[:results] = tps
        initialize_metric(@average_metric_list,"rtps",dev)
        @average_metric_list["rtps"].find {|key_data| key_data[:dev_name] == dev}[:results] = rtps
        initialize_metric(@average_metric_list,"wtps",dev)
        @average_metric_list["wtps"].find {|key_data| key_data[:dev_name] == dev}[:results] = wtps
        initialize_metric(@average_metric_list,"bread/s",dev)
        @average_metric_list["bread/s"].find {|key_data| key_data[:dev_name] == dev}[:results] = breads
        initialize_metric(@average_metric_list,"bwrtn/s",dev)
        @average_metric_list["bwrtn/s"].find {|key_data| key_data[:dev_name] == dev}[:results] = bwrtns
      end
    end
  end
end
