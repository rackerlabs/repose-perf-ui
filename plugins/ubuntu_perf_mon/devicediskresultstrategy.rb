require_relative 'abstractstrategy.rb'

class DeviceDiskResultStrategy < AbstractStrategy
  attr_accessor :average_metric_list,:detailed_metric_list 

  def self.metric_description
    {
      "tps" => "Indicate the number of transfers per second that were issued to the device. Multiple logical requests can be combined into a single I/O request to the device. A transfer is of indeterminate size.",
      "rd_sec/s" => "Number of sectors read from the device. The size of a sector is 512 bytes.",
      "wr_sec/s" => "Number of sectors written to the device. The size of a sector is 512 bytes.",
      "avgrq-sz" => "The average size (in sectors) of the requests that were issued to the device.",
      "avgqu-sz" => "The average queue length of the requests that were issued to the device.",
      "await" => "The average time (in milliseconds) for I/O requests issued to the device to be served. This includes the time spent by the requests in queue and the time spent servicing them.",
      "svctm" => "The average service time (in milliseconds) for I/O requests that were issued to the device.",
      "%util" => "Percentage of CPU time during which I/O requests were issued to the device (bandwidth utilization for the device). Device saturation occurs when this value is close to 100%."
    }
  end

  def initialize(name, test_type, id, config_path = nil)
  
    @average_metric_list = {
      "tps" => [],
      "rd_sec/s" => [],
      "wr_sec/s" => [],
      "avgrq-sz" => [],
      "avgqu-sz" => [],
      "await" => [],
      "svctm" => [],
      "%util" => []
    }

    @detailed_metric_list = {
      "tps" => [],
      "rd_sec/s" => [],
      "wr_sec/s" => [],
      "avgrq-sz" => [],
      "avgqu-sz" => [],
      "await" => [],
      "svctm" => [],
      "%util" => []
    }

    super(name,test_type,id,config_path)
  end 

  def populate_metric(entry, id, start, stop)
    Dir.glob("#{entry}/sysstats.log*").each do |sysstats_file|
      #execute file and get back io results
      p "sar -d -f #{sysstats_file}"
      io_results = `sar -d -f #{sysstats_file}`.split(/\r?\n/)
      io_results.each do |result|
        result.scan(/Average:\s+(\S+)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)$/).map do |device,tps,rd_secs,wr_secs,avgrqsz,avgqusz,await,svctm,util|
          #get device name and then time
          #only use time that's between start and end (in the 24 hour period the time has to be between those 2)
          dev = "#{File.basename(sysstats_file)}-#{device}"
          initialize_metric(@average_metric_list,"tps",dev)
          @average_metric_list["tps"].find {|key_data| key_data[:dev_name] == dev}[:results] = tps
          initialize_metric(@average_metric_list,"rd_sec/s",dev)
          @average_metric_list["rd_sec/s"].find {|key_data| key_data[:dev_name] == dev}[:results] = rd_secs
          initialize_metric(@average_metric_list,"wr_sec/s",dev)
          @average_metric_list["wr_sec/s"].find {|key_data| key_data[:dev_name] == dev}[:results] = wr_secs
          initialize_metric(@average_metric_list,"avgrq-sz",dev)
          @average_metric_list["avgrq-sz"].find {|key_data| key_data[:dev_name] == dev}[:results] = avgrqsz
          initialize_metric(@average_metric_list,"avgqu-sz",dev)
          @average_metric_list["avgqu-sz"].find {|key_data| key_data[:dev_name] == dev}[:results] = avgqusz
          initialize_metric(@average_metric_list,"%util",dev)
          @average_metric_list["%util"].find {|key_data| key_data[:dev_name] == dev}[:results] = avgqusz
          initialize_metric(@average_metric_list,"await",dev)
          @average_metric_list["await"].find {|key_data| key_data[:dev_name] == dev}[:results] = avgqusz
          initialize_metric(@average_metric_list,"svctm",dev)
          @average_metric_list["svctm"].find {|key_data| key_data[:dev_name] == dev}[:results] = avgqusz
        end
        result.scan(/(\d+:\d+:\d+ \S+)\s+(\S+)\s+(\S+)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)$/).map do |time,device,tps,rd_secs,wr_secs,avgrqsz,avgqusz,await,svctm,util|
          #get device name and then time
          #only use time that's between start and end (in the 24 hour period the time has to be between those 2)
          dev = "#{File.basename(sysstats_file)}-#{device}"
          initialize_metric(@detailed_metric_list,"tps",dev)
          @detailed_metric_list["tps"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value => tps}
          initialize_metric(@detailed_metric_list,"rd_sec/s",dev)
          @detailed_metric_list["rd_sec/s"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value => rd_secs}
          initialize_metric(@detailed_metric_list,"wr_sec/s",dev)
          @detailed_metric_list["wr_sec/s"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value => wr_secs}
          initialize_metric(@detailed_metric_list,"avgrq-sz",dev)
          @detailed_metric_list["avgrq-sz"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value => avgrqsz}
          initialize_metric(@detailed_metric_list,"avgqu-sz",dev)
          @detailed_metric_list["avgqu-sz"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value => avgqusz}
          initialize_metric(@detailed_metric_list,"%util",dev)
          @detailed_metric_list["%util"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value => avgqusz}
          initialize_metric(@detailed_metric_list,"await",dev)
          @detailed_metric_list["await"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value => avgqusz}
          initialize_metric(@detailed_metric_list,"svctm",dev)
          @detailed_metric_list["svctm"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value => avgqusz}
        end
      end
    end
  end
end
