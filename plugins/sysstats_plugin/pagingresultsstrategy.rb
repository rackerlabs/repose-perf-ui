require_relative 'abstractstrategy.rb'


class DiskPagingResultStrategy < AbstractStrategy
  attr_accessor :average_metric_list,:detailed_metric_list 

  def load_metric(name,test_type,id, config_path = nil)
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
    super(name,test_type,id,config_path)
  end 

  def populate_metric(entry, id, start, stop)
    Dir.glob("#{entry}/sysstats.log*").each do |sysstats_file|
      #execute file and get back io results
      p "sar -d -f #{sysstats_file}"
      io_results = `sar -B -f #{sysstats_file}`.split(/\r?\n/)
      io_results.each do |result|
        result.scan(/Average:\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)$/).map do |pgpgins,pgpgouts,faults, majflts, pgfrees, pgscanks, pgscands, pgsteals, vmeff|
          #get device name and then time
          #only use time that's between start and end (in the 24 hour period the time has to be between those 2)
          dev = File.basename(sysstats_file)
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
