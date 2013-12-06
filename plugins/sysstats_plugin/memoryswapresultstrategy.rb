require_relative 'abstractstrategy.rb'

class MemorySwapResultStrategy < AbstractStrategy
  attr_accessor :average_metric_list,:detailed_metric_list 

  def self.metric_description
    {
      "kbswpfree" => "",
      "kbswpused" => "",
      "%swpused" => "",
      "kbswpcad" => "",
      "%swpcad" => ""
    }
  end

  def initialize(db, fs_ip, application, name, test_type, id)
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
    super(db, fs_ip, application, name, test_type, id)
  end 

  def populate_metric(entry, name, id, start, stop)
    open(entry).readlines.each do |result|
      result.scan(/Average:\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)$/).map do |kbswpfree, kbswpused, swpused, kbswpcad,swpcad|
        dev = File.basename(entry)
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
      result.scan(/(\d+:\d+:\d+ \S+)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)$/).map do |time, kbswpfree, kbswpused, swpused, kbswpcad,swpcad|
        dev = File.basename(entry)
        initialize_metric(@detailed_metric_list,"kbswpfree",dev)
        @detailed_metric_list["kbswpfree"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value => kbswpfree}
        initialize_metric(@detailed_metric_list,"kbswpused",dev)
        @detailed_metric_list["kbswpused"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value =>  kbswpused}
        initialize_metric(@detailed_metric_list,"%swpused",dev)
        @detailed_metric_list["%swpused"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value => swpused}
        initialize_metric(@detailed_metric_list,"kbswpcad",dev)
        @detailed_metric_list["kbswpcad"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value => kbswpcad}
        initialize_metric(@detailed_metric_list,"%swpcad",dev)
        @detailed_metric_list["%swpcad"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value =>  swpcad}
      end
    end
  end
end
