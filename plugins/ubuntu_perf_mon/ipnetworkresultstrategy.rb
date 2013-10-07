require_relative 'abstractstrategy.rb'

class IpNetworkResultStrategy < AbstractStrategy
  attr_accessor :average_metric_list,:detailed_metric_list 
  def initialize(name,test_type,id, config_path = nil)
    @average_metric_list = {
      "irec/s" => [],
      "fwddgm/s" => [],
      "idel/s" => [],
      "org/s" => [],
      "asmrq/s" => [],
      "asmok/s" => [],
      "fragok/s" => [],
      "fragcrt/s" => []
    }

    @detailed_metric_list = {
      "irec/s" => [],
      "fwddgm/s" => [],
      "idel/s" => [],
      "org/s" => [],
      "asmrq/s" => [],
      "asmok/s" => [],
      "fragok/s" => [],
      "fragcrt/s" => []
    }
    super(name,test_type,id,config_path)
  end 

  def populate_metric(entry, id, start, stop)
    Dir.glob("#{entry}/sysstats.log*").each do |sysstats_file|
      #execute file and get back io results
      p "sar -d -f #{sysstats_file}"
      io_results = `sar -n IP -f #{sysstats_file}`.split(/\r?\n/)
      io_results.each do |result|
        result.scan(/Average:\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)$/).map do |irecs,fwddgms,idels,orgs,asmrqs,asmoks,fragoks,fragcrts|
          #get device name and then time
          #only use time that's between start and end (in the 24 hour period the time has to be between those 2)
          dev = File.basename(sysstats_file)
          initialize_metric(@average_metric_list,"irec/s",dev)
          @average_metric_list["irec/s"].find {|key_data| key_data[:dev_name] == dev}[:results] = irecs
          initialize_metric(@average_metric_list,"fwddgm/s",dev)
          @average_metric_list["fwddgm/s"].find {|key_data| key_data[:dev_name] == dev}[:results] = fwddgms
          initialize_metric(@average_metric_list,"idel/s",dev)
          @average_metric_list["idel/s"].find {|key_data| key_data[:dev_name] == dev}[:results] = idels
          initialize_metric(@average_metric_list,"org/s",dev)
          @average_metric_list["org/s"].find {|key_data| key_data[:dev_name] == dev}[:results] = orgs
          initialize_metric(@average_metric_list,"asmrq/s",dev)
          @average_metric_list["asmrq/s"].find {|key_data| key_data[:dev_name] == dev}[:results] = asmrqs
          initialize_metric(@average_metric_list,"asmok/s",dev)
          @average_metric_list["asmok/s"].find {|key_data| key_data[:dev_name] == dev}[:results] = asmoks
          initialize_metric(@average_metric_list,"fragok/s",dev)
          @average_metric_list["fragok/s"].find {|key_data| key_data[:dev_name] == dev}[:results] = fragoks
          initialize_metric(@average_metric_list,"fragcrt/s",dev)
          @average_metric_list["fragcrt/s"].find {|key_data| key_data[:dev_name] == dev}[:results] = fragcrts
        end
        result.scan(/(\d+:\d+:\d+ \S+)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)$/).map do |time,irecs,fwddgms,idels,orgs,asmrqs,asmoks,fragoks,fragcrts|
          #get device name and then time
          #only use time that's between start and end (in the 24 hour period the time has to be between those 2)
          dev = File.basename(sysstats_file)
          initialize_metric(@detailed_metric_list,"irec/s",dev)
          @detailed_metric_list["irec/s"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value => irecs}
          initialize_metric(@detailed_metric_list,"fwddgm/s",dev)
          @detailed_metric_list["fwddgm/s"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value => fwddgms}
          initialize_metric(@detailed_metric_list,"idel/s",dev)
          @detailed_metric_list["idel/s"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value => idels}
          initialize_metric(@detailed_metric_list,"org/s",dev)
          @detailed_metric_list["org/s"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value => orgs}
          initialize_metric(@detailed_metric_list,"asmrq/s",dev)
          @detailed_metric_list["asmrq/s"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value => asmrqs}
          initialize_metric(@detailed_metric_list,"asmok/s",dev)
          @detailed_metric_list["asmok/s"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value => asmoks}
          initialize_metric(@detailed_metric_list,"fragok/s",dev)
          @detailed_metric_list["fragok/s"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value => fragoks}
          initialize_metric(@detailed_metric_list,"fragcrt/s",dev)
          @detailed_metric_list["fragcrt/s"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value => fragcrts}
        end
      end
    end
  end
end
