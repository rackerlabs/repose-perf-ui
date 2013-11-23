require 'json'
require 'yaml'
require_relative 'models.rb'

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

