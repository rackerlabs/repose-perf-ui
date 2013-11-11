require_relative 'abstractstrategy.rb'

class KernelResultStrategy < AbstractStrategy
  attr_accessor :average_metric_list,:detailed_metric_list 

  def initialize(name,test_type,id, config_path = nil)
    @average_metric_list = {
      "dentunusd" => [],
      "file-nr" => [],
      "inode-nr" => [],
      "pty-nr" => []
    }

    @detailed_metric_list = {
      "dentunusd" => [],
      "file-nr" => [],
      "inode-nr" => [],
      "pty-nr" => []
    }
    super(name,test_type,id,config_path)
  end 

  def populate_metric(entry, id, start, stop)
    Dir.glob("#{entry}/sysstats.log*").each do |sysstats_file|
      #execute file and get back io results
      io_results = `sar -v -f #{sysstats_file}`.split(/\r?\n/)
      io_results.each do |result|
        result.scan(/Average:\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)$/).map do |dentunusd, filenr, inodenr, ptynr|
          #get device name and then time
          #only use time that's between start and end (in the 24 hour period the time has to be between those 2)
          dev = File.basename(sysstats_file)
          initialize_metric(@average_metric_list,"dentunusd",dev)
          @average_metric_list["dentunusd"].find {|key_data| key_data[:dev_name] == dev}[:results] = dentunusd
          initialize_metric(@average_metric_list,"file-nr",dev)
          @average_metric_list["file-nr"].find {|key_data| key_data[:dev_name] == dev}[:results] = filenr
          initialize_metric(@average_metric_list,"inode-nr",dev)
          @average_metric_list["inode-nr"].find {|key_data| key_data[:dev_name] == dev}[:results] = inodenr
          initialize_metric(@average_metric_list,"pty-nr",dev)
          @average_metric_list["pty-nr"].find {|key_data| key_data[:dev_name] == dev}[:results] = ptynr
        end
        result.scan(/(\d+:\d+:\d+ \S+)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)$/).map do |time, dentunusd, filenr, inodenr, ptynr|
          dev = File.basename(sysstats_file)
          initialize_metric(@detailed_metric_list,"dentunusd",dev)
          @detailed_metric_list["dentunusd"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value => dentunusd}
          initialize_metric(@detailed_metric_list,"file-nr",dev)
          @detailed_metric_list["file-nr"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value =>  filenr}
          initialize_metric(@detailed_metric_list,"inode-nr",dev)
          @detailed_metric_list["inode-nr"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value => inodenr}
          initialize_metric(@detailed_metric_list,"pty-nr",dev)
          @detailed_metric_list["pty-nr"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value =>  ptynr}
        end
      end
    end
  end
end
