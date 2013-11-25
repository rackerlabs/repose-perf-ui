module PluginModule
  class PastPluginResults
  
    def self.format_results(results,metric,temp_results, header_descriptions={})
      if results.length > 0
        temp_results[metric] = {}
        temp_results[metric][:content] = {}
        temp_results[metric][:headers] = results.keys 
        temp_results[metric][:description] = header_descriptions
        results.each do |k,v|
          v.each do |y|
            temp_results[metric][:content][y[:dev_name]] = []
            temp_results[metric][:description][y[:dev_name]] = y[:description]
          end
        end
        results.each do |k,v|
          v.each do |y|
            temp_results[metric][:content][y[:dev_name]] << y[:results]
          end
        end
        temp_results
      end
    end
  end 
  
  class PluginResult
    attr_reader :strategy
  
    def initialize(strategy)
      @strategy = strategy
    end
  
    def retrieve_detailed_results
      @strategy.detailed_metric_list
    end
  
    def retrieve_average_results
      @strategy.average_metric_list
    end
  end
end