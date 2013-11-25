require_relative 'abstractstrategy.rb'

class GarbageCollectionStrategy < ReposeAbstractStrategy

  attr_accessor :average_metric_list,:detailed_metric_list 

  def initialize(db, fs_ip, application, name, test_type, id)
    @average_metric_list = {
      "PSMarkSweep.CollectionTime" => [],
      "PSMarkSweep.CollectionCount" => [],
      "PSScavenge.CollectionTime" => [],
      "PSScavenge.CollectionCount" => []
    }

    @detailed_metric_list = {
      "PSMarkSweep.CollectionTime" => [],
      "PSMarkSweep.CollectionCount" => [],
      "PSScavenge.CollectionTime" => [],
      "PSScavenge.CollectionCount" => []
    }
    super(db, fs_ip, application, name, test_type, id)
  end 

  def populate_metric(entry, name, id, start, stop)
    open(entry).readlines.each do |line|
      line.scan(/^localhost.*sun_management_GarbageCollectorImpl\.(\w+)\.(\w+)\s+(\d*\.?\d*?)\s+(\d+)$/).map do |metric,counter,value,timestamp|
        initialize_metric(@detailed_metric_list,"#{metric}.#{counter}", name)
        @detailed_metric_list["#{metric}.#{counter}"].find {|key_data| key_data[:dev_name] == name}[:results] << {:time => timestamp, :value => value}
      end
    end
    @detailed_metric_list.each do |key, v|
      initialize_metric(@average_metric_list, key, name)
      v.each do | dev_name_entry |
        average_results = dev_name_entry[:results].map {|result| result[:value].to_f}
        average = average_results.inject(:+).to_f / average_results.length
        @average_metric_list[key].find {|key_data| key_data[:dev_name] == name}[:results] = average
      end
    end
  end
end
