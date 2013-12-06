require_relative 'abstractstrategy.rb'

class IOTransferResultStrategy < AbstractStrategy
  attr_accessor :average_metric_list,:detailed_metric_list 

  def load_metric(name, test_type, id, config_path = nil)
  
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

    super(name,test_type,id,config_path)
  end 


  def populate_metric(entry, id, start, stop)
    Dir.glob("#{entry}/sysstats.log*").each do |sysstats_file|
      #execute file and get back io results
      p "sar -d -f #{sysstats_file}"
      io_results = `sar -b -f #{sysstats_file}`.split(/\r?\n/)
      io_results.each do |result|
        result.scan(/Average:\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)/).map do |tps,rtps,wtps,breads,bwrtns|
          #get device name and then time
          dev = File.basename(sysstats_file)
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
end
