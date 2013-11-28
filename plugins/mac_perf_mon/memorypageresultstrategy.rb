require_relative 'abstractstrategy.rb'

class MemoryPageResultStrategy < AbstractStrategy
  attr_accessor :average_metric_list,:detailed_metric_list 

  def initialize(name,test_type,id, config_path = nil)
    @average_metric_list = {
      "frmpg/s" => [],
      "bufpg/s" => [],
      "campg/s" => []
    }

    @detailed_metric_list = {
      "frmpg/s" => [],
      "bufpg/s" => [],
      "campg/s" => []
    }
    super(name,test_type,id,config_path)
  end 

  def populate_metric(entry, id, start, stop)
    Dir.glob("#{entry}/sysstats.log*").each do |sysstats_file|
      #execute file and get back io results
      io_results = `sar -R -f #{sysstats_file}`.split(/\r?\n/)
      io_results.each do |result|
        result.scan(/Average:\s+(-?\d+\.?\d*?)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)$/).map do |frmpgs, bufpgs, campgs|
          dev = File.basename(sysstats_file)
          initialize_metric(@average_metric_list,"frmpg/s",dev)
          @average_metric_list["frmpg/s"].find {|key_data| key_data[:dev_name] == dev}[:results] = frmpgs
          initialize_metric(@average_metric_list,"bufpg/s",dev)
          @average_metric_list["bufpg/s"].find {|key_data| key_data[:dev_name] == dev}[:results] = bufpgs
          initialize_metric(@average_metric_list,"campg/s",dev)
          @average_metric_list["campg/s"].find {|key_data| key_data[:dev_name] == dev}[:results] = campgs
        end
        result.scan(/(\d+:\d+:\d+ \S+)\s+(\S+)\s+(-?\d+\.?\d*?)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)$/).map do |time, frmpgs, bufpgs, campgs|
          dev = File.basename(sysstats_file)
          initialize_metric(@detailed_metric_list,"frmpg/s",dev)
          @detailed_metric_list["frmpg/s"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value => frmpgs}
          initialize_metric(@detailed_metric_list,"bufpg/s",dev)
          @detailed_metric_list["bufpg/s"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value => bufpgs}
          initialize_metric(@detailed_metric_list,"campg/s",dev)
          @detailed_metric_list["campg/s"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value => campgs}
        end
      end
    end
  end
end
