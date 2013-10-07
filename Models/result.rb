require 'json'
require 'yaml'
require_relative 'models.rb'

class Result

  attr_reader :date, :length, :avg, :throughput, :errors, :id, :tag 
  attr_accessor :jmx_results, :network_results

  def initialize(date, length, avg, throughput, errors, id, tag, jmx_results = {}, network_results = {})
    @date = date
    @avg = avg
    @tag = tag
    @length = length
    @throughput = throughput
    @errors = errors
    @id = id
    @jmx_results = jmx_results
    @network_results = network_results
  end
end

class SummaryResult
  attr_reader :date, :throughput, :avg, :errors

  def initialize(date, throughput, avg, errors)
    @date = date
    @throughput = throughput
    @avg = avg
    @errors = errors
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



