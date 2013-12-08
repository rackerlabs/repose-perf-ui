require_relative 'abstractstrategy.rb'

module SysstatsPluginModule
  class DiskPagingResultStrategy < AbstractStrategy
    attr_accessor :average_metric_list,:detailed_metric_list 
  
    def self.metric_description
      {
        "kbswpfree" => "",
        "kbswpused" => "",
        "%swpused" => "",
        "kbswpcad" => "",
        "%swpcad" => ""
      }
    end
  
    def initialize(db, fs_ip, application, name, test_type, id)
      @average_metric_list = {
        "pgpgin/s" => [],
        "pgpgout/s" => [],
        "fault/s" => [],
        "majflt/s" => [],
        "pgfree/s" => [],
        "pgscank/s" => [],
        "pgscand/s" => [],
        "pgsteal/s" => [],
        "%vmeff" => []
      }
  
      @detailed_metric_list = {
        "pgpgin/s" => "",
        "pgpgout/s" => "",
        "fault/s" => "",
        "majflt/s" => "",
        "pgfree/s" => "",
        "pgscank/s" => "",
        "pgscand/s" => "",
        "pgsteal/s" => "",
        "%vmeff" => ""
      }
      super(db, fs_ip, application, name, test_type, id)
    end 
  
    def populate_metric(entry, name, id, start, stop)
      open(entry).readlines.each do |result|
        result.scan(/Average:\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)$/).map do |pgpgins,pgpgouts,faults, majflts, pgfrees, pgscanks, pgscands, pgsteals, vmeff|
          #get device name and then time
          #only use time that's between start and end (in the 24 hour period the time has to be between those 2)
          dev = File.basename(entry)
          initialize_metric(@average_metric_list,"pgpgin/s",dev)
          @average_metric_list["pgpgin/s"].find {|key_data| key_data[:dev_name] == dev}[:results] = pgpgins
          initialize_metric(@average_metric_list,"pgpgout/s",dev)
          @average_metric_list["pgpgout/s"].find {|key_data| key_data[:dev_name] == dev}[:results] = pgpgouts
          initialize_metric(@average_metric_list,"fault/s",dev)
          @average_metric_list["fault/s"].find {|key_data| key_data[:dev_name] == dev}[:results] = faults
          initialize_metric(@average_metric_list,"majflt/s",dev)
          @average_metric_list["majflt/s"].find {|key_data| key_data[:dev_name] == dev}[:results] = majflts
          initialize_metric(@average_metric_list,"pgfree/s",dev)
          @average_metric_list["pgfree/s"].find {|key_data| key_data[:dev_name] == dev}[:results] = pgfrees
          initialize_metric(@average_metric_list,"pgscank/s",dev)
          @average_metric_list["pgscank/s"].find {|key_data| key_data[:dev_name] == dev}[:results] = pgscanks
          initialize_metric(@average_metric_list,"pgscand/s",dev)
          @average_metric_list["pgscand/s"].find {|key_data| key_data[:dev_name] == dev}[:results] = pgscands
          initialize_metric(@average_metric_list,"pgsteal/s",dev)
          @average_metric_list["pgsteal/s"].find {|key_data| key_data[:dev_name] == dev}[:results] = pgsteals
          initialize_metric(@average_metric_list,"%vmeff",dev)
          @average_metric_list["%vmeff"].find {|key_data| key_data[:dev_name] == dev}[:results] = vmeff
        end
      end
    end
  end
end