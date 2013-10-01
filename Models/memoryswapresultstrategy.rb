require_relative 'result.rb'

class MemorySwapResultStrategy < AbstractStrategy
  attr_accessor :average_metric_list,:detailed_metric_list 

  def initialize(name,test_type,id, config_path = nil)
    @average_metric_list = {
      "kbswpfree" => [],
      "kbswpused" => [],
      "%swpused" => [],
      "kbswpcad" => [],
      "%swpcad" => []
    }

    @detailed_metric_list = {
      "kbswpfree" => [],
      "kbswpused" => [],
      "%swpused" => [],
      "kbswpcad" => [],
      "%swpcad" => []
    }
    super(name,test_type,id,config_path)
  end 

  def populate_metric(entry, id, start, stop)
    Dir.glob("#{entry}/sysstats.log*").each do |sysstats_file|
      #execute file and get back io results
      p "sar -d -f #{sysstats_file}"
      io_results = `sar -S -f #{sysstats_file}`.split(/\r?\n/)
      io_results.each do |result|
        result.scan(/Average:\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)$/).map do |kbswpfree, kbswpused, swpused, kbswpcad,swpcad|
          #get device name and then time
          #only use time that's between start and end (in the 24 hour period the time has to be between those 2)
          dev = File.basename(sysstats_file)
          initialize_metric(@average_metric_list,"kbswpfree",dev)
          @average_metric_list["kbswpfree"].find {|key_data| key_data[:dev_name] == dev}[:results] = kbswpfree
          initialize_metric(@average_metric_list,"kbswpused",dev)
          @average_metric_list["kbswpused"].find {|key_data| key_data[:dev_name] == dev}[:results] = kbswpused
          initialize_metric(@average_metric_list,"%swpused",dev)
          @average_metric_list["%swpused"].find {|key_data| key_data[:dev_name] == dev}[:results] = swpused
          initialize_metric(@average_metric_list,"kbswpcad",dev)
          @average_metric_list["kbswpcad"].find {|key_data| key_data[:dev_name] == dev}[:results] = kbswpcad
          initialize_metric(@average_metric_list,"%swpcad",dev)
          @average_metric_list["%swpcad"].find {|key_data| key_data[:dev_name] == dev}[:results] = swpcad
        end
      end
    end
  end
end
