class PastNetworkResults
  include ResultModule
  attr_reader :test_list

  def self.format_network(network_results,metric,temp_network_results, header_descriptions={})
    temp_network_results[metric] = {}
    temp_network_results[metric][:content] = {}
    temp_network_results[metric][:headers] = network_results.keys 
    temp_network_results[metric][:description] = header_descriptions
    network_results.each do |k,v|
      v.each do |y|
        temp_network_results[metric][:content][y[:dev_name]] = []
        temp_network_results[metric][:description][y[:dev_name]] = y[:description]
      end
    end
    network_results.each do |k,v|
      v.each do |y|
        temp_network_results[metric][:content][y[:dev_name]] << y[:results]
      end
    end
    temp_network_results
  end
end 

class NetworkResult
  attr_reader :networkStrategy

  def initialize(networkStrategy)
    @networkStrategy = networkStrategy
  end

  def retrieve_detailed_results
    @networkStrategy.detailed_metric_list
  end

  def retrieve_average_results
    @networkStrategy.average_metric_list
  end
end
