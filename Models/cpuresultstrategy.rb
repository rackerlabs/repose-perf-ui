require_relative 'result.rb'

class CpuResultStrategy < AbstractStrategy

  attr_accessor :average_metric_list,:detailed_metric_list 

  def initialize(name,test_type,id, config_path = nil)
    @average_metric_list = {
      "%user" => [],
      "%nice" => [],
      "%system" => [],
      "%iowait" => [],
      "%steal" => [],
      "%idle" => []
    }

    @detailed_metric_list = {
      "%user" => [],
      "%nice" => [],
      "%system" => [],
      "%iowait" => [],
      "%steal" => [],
      "%idle" => []
    }
    super(name,test_type,id,config_path)
  end 

  def populate_metric(entry, id, start, stop)
    Dir.glob("#{entry}/sysstats.log*").each do |sysstats_file|
      #execute file and get back io results
      io_results = `sar -u -f #{sysstats_file}`.split(/\r?\n/)
      io_results.each do |result|
        result.scan(/Average:\s+(\S+)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)$/).map do |cpu,user,nice,system,iowait,steal,idle|
          #get device name and then time
          #only use time that's between start and end (in the 24 hour period the time has to be between those 2)
          dev = "#{File.basename(sysstats_file)}-#{cpu}"
          initialize_metric(@average_metric_list,"%user",dev)
          @average_metric_list["%user"].find {|key_data| key_data[:dev_name] == dev}[:results] = user
          initialize_metric(@average_metric_list,"%nice",dev)
          @average_metric_list["%nice"].find {|key_data| key_data[:dev_name] == dev}[:results] = nice
          initialize_metric(@average_metric_list,"%system",dev)
          @average_metric_list["%system"].find {|key_data| key_data[:dev_name] == dev}[:results] = system
          initialize_metric(@average_metric_list,"%iowait",dev)
          @average_metric_list["%iowait"].find {|key_data| key_data[:dev_name] == dev}[:results] = iowait
          initialize_metric(@average_metric_list,"%steal",dev)
          @average_metric_list["%steal"].find {|key_data| key_data[:dev_name] == dev}[:results] = steal
          initialize_metric(@average_metric_list,"%idle",dev)
          @average_metric_list["%idle"].find {|key_data| key_data[:dev_name] == dev}[:results] = idle
        end
      end
    end
  end
end
