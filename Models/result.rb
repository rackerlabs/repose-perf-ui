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

class AbstractStrategy
  include ResultModule

  attr_reader :folder_location
  def initialize
  end


  def initialize(name, test_type,id, config_path)
    config = config(config_path)
    test_type.chomp!("_test")
    @folder_location = "#{config['home_dir']}/files/apps/#{name}/results/#{test_type}"
    Dir.glob("#{folder_location}/tmp_*").each do |entry| 
      if File.directory?(entry)
        #get directory
        #get begin time, end time, tag name in entry meta file
        test_type = "load" if test_type == "adhoc"
        json_file = JSON.parse(File.read("#{entry}/meta/#{test_type}_test.json"))
        if json_file['id'] == id
          populate_metric(entry, id, json_file['start'], json_file['stop'])
          break
        end
      end
    end
  end

  def initialize_metric(list,key, dev)
    unless list[key].find{|key_data| key_data.has_key?("dev_name")}
      list[key] << {:dev_name  => dev, :results => []}
    end
  end 
end

