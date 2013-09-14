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

class IOTransferResultStrategy < AbstractStrategy
  attr_accessor :average_metric_list,:detailed_metric_list 

  def initialize(name, test_type, id, config_path = nil)
  
    @average_metric_list = {
      "tps" => [],
      "rtps" => [],
      "wtps" => [],
      "bread/s" => [],
      "bwrtn/s" => []
    }

    @detailed_metric_list = {
      "tps" => [],
      "rtps" => [],
      "wtps" => [],
      "bread/s" => [],
      "bwrtn/s" => []
    }

    super(name,test_type,id,config_path)
  end 


  def populate_metric(entry, id, start, stop)
    Dir.glob("#{entry}/sysstats.log*").each do |sysstats_file|
      #execute file and get back io results
      p "sar -d -f #{sysstats_file}"
      io_results = `sar -b -f #{sysstats_file}`.split(/\r?\n/)
      io_results.each do |result|
        result.scan(/Average:\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)/).map do |tps,rtps,wtps,breads,bwrtns|
          #get device name and then time
          dev = File.basename(sysstats_file)
          #only use time that's between start and end (in the 24 hour period the time has to be between those 2)
          initialize_metric(@average_metric_list,"tps",dev)
          @average_metric_list["tps"].find {|key_data| key_data[:dev_name] == dev}[:results] = tps
          initialize_metric(@average_metric_list,"rtps",dev)
          @average_metric_list["rtps"].find {|key_data| key_data[:dev_name] == dev}[:results] = rtps
          initialize_metric(@average_metric_list,"wtps",dev)
          @average_metric_list["wtps"].find {|key_data| key_data[:dev_name] == dev}[:results] = wtps
          initialize_metric(@average_metric_list,"bread/s",dev)
          @average_metric_list["bread/s"].find {|key_data| key_data[:dev_name] == dev}[:results] = breads
          initialize_metric(@average_metric_list,"bwrtn/s",dev)
          @average_metric_list["bwrtn/s"].find {|key_data| key_data[:dev_name] == dev}[:results] = bwrtns
        end
      end
    end
  end
end


