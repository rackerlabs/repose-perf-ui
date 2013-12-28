require_relative 'abstractstrategy.rb'

module NewRelicRestPluginModule
  class NewRelicTimeSeriesStrategy < NewRelicRestPluginModule::AbstractStrategy
  
    attr_accessor :average_metric_list,:detailed_metric_list 
    
    def self.metric_description
      {
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
      key = name.sub(/newrelic\.out_/,'')
      if results
        average_results = 0
        datapoint_results = {}
        average_results = {}
        results.each do |entry|
          datapoint_results[entry['name']] = [] unless datapoint_results[entry['name']]
          datapoint_results[entry['name']] <<  {:time => DateTime.parse(entry['begin']).to_time.to_i, :value => entry[key]}
          average_results[entry['name']] = 0 unless average_results[entry['name']]
          average_results[entry['name']] = average_results[entry['name']] + entry[key].to_f
        end
          
        datapoint_results.each do |k, entry|
          @detailed_metric_list[key] = [] unless @detailed_metric_list[key] 
          @detailed_metric_list[key] << {:dev_name => k, :results => entry}
          @average_metric_list[key] = [] unless @average_metric_list[key] 
          @average_metric_list[key] << {:dev_name => k, :results => (average_results[k]/entry.length)}
        end
      end
    end
  end
end