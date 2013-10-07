require_relative 'abstractstrategy.rb'

class MemoryUtilizationResultStrategy < AbstractStrategy
  attr_accessor :average_metric_list,:detailed_metric_list 

  def initialize(name,test_type,id, config_path = nil)
    @average_metric_list = {
      "kbmemfree" => [],
      "kbmemused" => [],
      "%memused" => [],
      "kbbuffers" => [],
      "kbcached" => [],
      "kbcommit" => [],
      "%commit" => [],
      "kbactive" => [],
      "kbinact" => []
    }

    @detailed_metric_list = {
      "kbmemfree" => [],
      "kbmemused" => [],
      "%memused" => [],
      "kbbuffers" => [],
      "kbcached" => [],
      "kbcommit" => [],
      "%commit" => [],
      "kbactive" => [],
      "kbinact" => []
    }
    super(name,test_type,id,config_path)
  end 

  def populate_metric(entry, id, start, stop)
    Dir.glob("#{entry}/sysstats.log*").each do |sysstats_file|
      #execute file and get back io results
      io_results = `sar -r -f #{sysstats_file}`.split(/\r?\n/)
      io_results.each do |result|
        result.scan(/Average:\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)$/).map do |kbmemfree,kbmemused,memused,kbbuffers,kbcached,kbcommit,commit,kbactive,kbinact|
          #get device name and then time
          #only use time that's between start and end (in the 24 hour period the time has to be between those 2)
          dev = File.basename(sysstats_file)
          initialize_metric(@average_metric_list,"kbmemfree",dev)
          @average_metric_list["kbmemfree"].find {|key_data| key_data[:dev_name] == dev}[:results] = kbmemfree
          initialize_metric(@average_metric_list,"kbmemused",dev)
          @average_metric_list["kbmemused"].find {|key_data| key_data[:dev_name] == dev}[:results] = kbmemused
          initialize_metric(@average_metric_list,"%memused",dev)
          @average_metric_list["%memused"].find {|key_data| key_data[:dev_name] == dev}[:results] = memused
          initialize_metric(@average_metric_list,"kbbuffers",dev)
          @average_metric_list["kbbuffers"].find {|key_data| key_data[:dev_name] == dev}[:results] = kbbuffers
          initialize_metric(@average_metric_list,"kbcached",dev)
          @average_metric_list["kbcached"].find {|key_data| key_data[:dev_name] == dev}[:results] = kbcached
          initialize_metric(@average_metric_list,"kbcommit",dev)
          @average_metric_list["kbcommit"].find {|key_data| key_data[:dev_name] == dev}[:results] = kbcommit
          initialize_metric(@average_metric_list,"kbinact",dev)
          @average_metric_list["kbinact"].find {|key_data| key_data[:dev_name] == dev}[:results] = kbinact
          initialize_metric(@average_metric_list,"%commit",dev)
          @average_metric_list["%commit"].find {|key_data| key_data[:dev_name] == dev}[:results] = commit
          initialize_metric(@average_metric_list,"kbactive",dev)
          @average_metric_list["kbactive"].find {|key_data| key_data[:dev_name] == dev}[:results] = kbactive
        end
        result.scan(/(\d+:\d+:\d+ \S+)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)$/).map do |time,kbmemfree,kbmemused,memused,kbbuffers,kbcached,kbcommit,commit,kbactive,kbinact|
          #get device name and then time
          #only use time that's between start and end (in the 24 hour period the time has to be between those 2)
          dev = File.basename(sysstats_file)
          initialize_metric(@detailed_metric_list,"kbmemfree",dev)
          @detailed_metric_list["kbmemfree"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value => kbmemfree}
          initialize_metric(@detailed_metric_list,"kbmemused",dev)
          @detailed_metric_list["kbmemused"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value => kbmemused}
          initialize_metric(@detailed_metric_list,"%memused",dev)
          @detailed_metric_list["%memused"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value => memused}
          initialize_metric(@detailed_metric_list,"kbbuffers",dev)
          @detailed_metric_list["kbbuffers"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value => kbbuffers}
          initialize_metric(@detailed_metric_list,"kbcached",dev)
          @detailed_metric_list["kbcached"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value => kbcached}
          initialize_metric(@detailed_metric_list,"kbcommit",dev)
          @detailed_metric_list["kbcommit"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value => kbcommit}
          initialize_metric(@detailed_metric_list,"kbinact",dev)
          @detailed_metric_list["kbinact"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value => kbinact}
          initialize_metric(@detailed_metric_list,"%commit",dev)
          @detailed_metric_list["%commit"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value => commit}
          initialize_metric(@detailed_metric_list,"kbactive",dev)
          @detailed_metric_list["kbactive"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value => kbactive}
        end
      end
    end
  end
end
