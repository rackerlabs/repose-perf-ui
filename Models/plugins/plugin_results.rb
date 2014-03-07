module PluginModule
  class PastPluginResults
    def self.plugin_type_strategies
      {
        :time_series => TimeSeriesResultsStrategy,
        :flat => FlatResultsStrategy,
        :blob => BlobResultsStrategy
      }
    end
    
  
    def self.format_results(results,metric,temp_results, header_descriptions={}, plugin_type=:time_series)
      if results && results.length > 0
        PastPluginResults.plugin_type_strategies[plugin_type].format_results(results,metric,temp_results, header_descriptions, plugin_type)
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
  
  class PluginView
    
    def self.retrieve_view(plugin_type, application_type)
      "#{plugin_type}_#{application_type}_plugin_results".to_sym
    end
    
    def self.retrieve_compare_view(plugin_type, application_type)
      "#{plugin_type}_results_plugin_test_compare".to_sym
    end
  end
  
  class TimeSeriesResultsStrategy
    def self.format_results(results,metric,temp_results, header_descriptions,plugin_type)
      temp_results[metric] = {}
      temp_results[metric][:content] = {}
      temp_results[metric][:headers] = results.keys 
      temp_results[metric][:description] = header_descriptions
      temp_results[metric][:plugin_type] = plugin_type
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
  
  class FlatResultsStrategy
    def self.format_results(results,metric,temp_results, header_descriptions,plugin_type)
      temp_results[metric] = {}
      temp_results[metric][:content] = results
      temp_results[metric][:plugin_type] = plugin_type
      temp_results
    end
  end

class BlobResultsStrategy
  def self.format_results(results,metric,temp_results, header_descriptions,plugin_type)
    temp_results[metric] = {}
    temp_results[metric][:content] = results
    temp_results[metric][:plugin_type] = plugin_type
    temp_results
  end
end

end
