require_relative 'abstractstrategy.rb'


module SysstatsPluginModule
  class KernelResultStrategy < AbstractStrategy
    attr_accessor :average_metric_list,:detailed_metric_list 
  
    def self.metric_description
      {
        "dentunusd" => "",
        "file-nr" => "",
        "inode-nr" => "",
        "pty-nr" => ""
      }
    end
  
    def initialize(db, fs_ip, application, name, test_type, id)
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
      super(db, fs_ip, application, name, test_type, id)
    end 
  
    def populate_metric(entry, name, id, start, stop)
      open(entry).readlines.each do |result|
        result.scan(/Average:\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)$/).map do |dentunusd, filenr, inodenr, ptynr|
          #get device name and then time
          #only use time that's between start and end (in the 24 hour period the time has to be between those 2)
          dev = File.basename(entry)
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
          dev = File.basename(entry)
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