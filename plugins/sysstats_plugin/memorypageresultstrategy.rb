require_relative 'abstractstrategy.rb'

class MemoryPageResultStrategy < AbstractStrategy
  attr_accessor :average_metric_list,:detailed_metric_list 

  def self.metric_description
    {
      "frmpg/s" => "",
      "bufpg/s" => "",
      "campg/s" => ""
    }
  end

  def initialize(db, fs_ip, application, name, test_type, id)
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
    super(db, fs_ip, application, name, test_type, id)
  end 

  def populate_metric(entry, name, id, start, stop)
    open(entry).readlines.each do |result|
      result.scan(/Average:\s+(-?\d+\.?\d*?)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)$/).map do |frmpgs, bufpgs, campgs|
        dev = File.basename(entry)
        initialize_metric(@average_metric_list,"frmpg/s",dev)
        @average_metric_list["frmpg/s"].find {|key_data| key_data[:dev_name] == dev}[:results] = frmpgs
        initialize_metric(@average_metric_list,"bufpg/s",dev)
        @average_metric_list["bufpg/s"].find {|key_data| key_data[:dev_name] == dev}[:results] = bufpgs
        initialize_metric(@average_metric_list,"campg/s",dev)
        @average_metric_list["campg/s"].find {|key_data| key_data[:dev_name] == dev}[:results] = campgs
      end
      result.scan(/(\d+:\d+:\d+ \S+)\s+(\S+)\s+(-?\d+\.?\d*?)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)$/).map do |time, frmpgs, bufpgs, campgs|
        dev = File.basename(entry)
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
