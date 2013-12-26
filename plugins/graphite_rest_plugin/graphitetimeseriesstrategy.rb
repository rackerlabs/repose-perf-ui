require_relative 'abstractstrategy.rb'

module GraphiteRestPluginModule
  class GraphiteTimeSeriesStrategy < GraphiteRestPluginModule::AbstractStrategy
  
    attr_accessor :average_metric_list,:detailed_metric_list 
    
    def self.metric_description
      {
        "carbon.agents.graphite-a.cache.overflow" => "",
        "carbon.agents.graphite-a.cache.queues" => "",
        "carbon.agents.graphite-a.cache.queries" => "",
        "carbon.agents.graphite-a.cache.size" => ""
      }
    end
  
    def initialize(db, fs_ip, application, name, test_type, id, metric_id)
      @average_metric_list = {}
  
      @detailed_metric_list = {}
      super(db, fs_ip, application, name, test_type, id, metric_id)
    end 
  
    def populate_metric(entry, name, id, start, stop)
      output = open(entry).read
      results = JSON.parse(output) if output
      puts entry, name, id, start, stop
      if results
        #1. set average_metric_list and detailed_metric_list
        #2. set metric_description (probably to nil or maybe load from config????)
        results.each do |target|
          datapoint_results = []
          average_results = 0
          target['datapoints'].each do |datapoint|
            datapoint_results << {:time => datapoint[1], :value => datapoint[0]}
            average_results = average_results + datapoint[0]
          end
          @detailed_metric_list[target['target']] = [
            {:dev_name => name, :results => datapoint_results}
          ]
          @average_metric_list[target['target']] = [
            {:dev_name => name, :results => (average_results/target['datapoints'].length)}
          ]
        end
      end
=begin
      open(entry).readlines.each do |line|
        line.scan(/^localhost.*sun_management_ThreadImpl\.(\w+)\s+(\d*\.?\d*?)\s+(\d+)$/).map do |counter,value,timestamp|
          initialize_metric(@detailed_metric_list, counter, name)
          @detailed_metric_list[counter].find {|key_data| key_data[:dev_name] == name}[:results] << {:time => timestamp, :value => value}
          #@detailed_metric_list[counter][:data].find {|key_data| key_data[:dev_name] == name}[:results] << {:time => timestamp, :value => value}
        end
      end
      @detailed_metric_list.each do |key, v|
        initialize_metric(@average_metric_list, key, name)
        v.each do | dev_name_entry |
          average_results = dev_name_entry[:results].map {|result| result[:value].to_f}
          average = average_results.inject(:+).to_f / average_results.length
          @average_metric_list[key].find {|key_data| key_data[:dev_name] == name}[:results] = average
          #@average_metric_list[key][:data].find {|key_data| key_data[:dev_name] == name}[:results] = average
        end
      end
=end      
    end
  end
end