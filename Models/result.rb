require 'json'
require 'yaml'
require_relative 'models.rb'

module SnapshotComparer
module Models
  class Result

  attr_reader :start, :length, :avg, :throughput, :errors, :id, :name, :description, :status
  attr_accessor :jmx_results, :network_results

  def initialize(start, length, avg, throughput, errors, name, description, id, status = :completed)
    @start = start
    @avg = avg
    @length = length
    @throughput = throughput
    @errors = errors
    @id = id
    @name = name
    @description = description
    @status = status
  end

  def self.get_overhead(results_one, results_two)
    overhead = {}
    results_one.each do |metric, value|
      overhead.merge!({metric => value.to_f - results_two[metric].to_f}) if results_two[metric]
    end
    overhead
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

class DetailedResult
  attr_reader :start, :throughput, :avg, :errors

  def initialize(start, throughput, avg, errors)
    @start = start
    @throughput = throughput
    @avg = avg
    @errors = errors
  end
end
end
end
