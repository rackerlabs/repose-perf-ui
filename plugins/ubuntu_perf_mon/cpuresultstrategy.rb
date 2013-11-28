require_relative 'abstractstrategy.rb'

class CpuResultStrategy < AbstractStrategy

  attr_accessor :average_metric_list,:detailed_metric_list 

  def self.metric_description
    {
      "%user" => "Percentage of CPU utilization that occurred while executing at the user level (application). Note that this field includes time spent running virtual processors.",
      "%usr" => "Percentage of CPU utilization that occurred while executing at the user level (application). Note that this field does NOT include time spent running virtual processors.",
      "%nice" => "Percentage of CPU utilization that occurred while executing at the user level with nice priority.",
      "%system" => "Percentage of CPU utilization that occurred while executing at the system level (kernel). Note that this field includes time spent servicing hardware and software interrupts.",
      "%iowait" => "Percentage of time that the CPU or CPUs were idle during which the system had an outstanding disk I/O request.",
      "%steal" => "Percentage of time spent in involuntary wait by the virtual CPU or CPUs while the hypervisor was servicing another virtual processor.",
      "%idle" => "Percentage of time that the CPU or CPUs were idle and the system did not have an outstanding disk I/O request."
    }
  end

  def initialize(application, name, test_type, id, config_path = nil)
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

  def populate_metric(entries, fs_ip, id, start, stop)
    entries.each do |entry|
      #execute file and get back io results
      #sar -u -f will execute on store_data and not here
      #io_results = `sar -u -f #{entry}`.split(/\r?\n/)
      open("http://#{fs_ip}#{entry}").readlines.each do |result|
      #io_results.each do |result|
        result.scan(/Average:\s+(\S+)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)$/).map do |cpu,user,nice,system,iowait,steal,idle|
          #get device name and then time
          #only use time that's between start and end (in the 24 hour period the time has to be between those 2)
          dev = "#{File.basename(entry)}-#{cpu}"
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
        result.scan(/(\d+:\d+:\d+ \S+)\s+(\S+)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)$/).map do |time, cpu,user,nice,system,iowait,steal,idle|
          dev = "#{File.basename(entry)}-#{cpu}"
          initialize_metric(@detailed_metric_list,"%user",dev)
          @detailed_metric_list["%user"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value => user}
          initialize_metric(@detailed_metric_list,"%nice",dev)
          @detailed_metric_list["%nice"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value => nice}
          initialize_metric(@detailed_metric_list,"%system",dev)
          @detailed_metric_list["%system"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value => system}
          initialize_metric(@detailed_metric_list,"%iowait",dev)
          @detailed_metric_list["%iowait"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value => iowait}
          initialize_metric(@detailed_metric_list,"%steal",dev)
          @detailed_metric_list["%steal"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value => steal}
          initialize_metric(@detailed_metric_list,"%idle",dev)
          @detailed_metric_list["%idle"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value => idle}
        end 
      end
    end
  end
end
