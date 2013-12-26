require_relative 'abstractstrategy.rb'

module ReposeJmxPluginModule
  class JvmThreadStrategy < ReposeJmxPluginModule::AbstractStrategy
  
    attr_accessor :average_metric_list,:detailed_metric_list 
    
    def self.metric_description
      {
        "PeakThreadCount" => "",
        "DaemonThreadCount" => "",
        "ThreadCount" => "",
        "TotalStartedThreadCount" => ""
      }
    end
    
    def self.preferred_order
      {
        "PeakThreadCount" => :desc,
        "DaemonThreadCount" => :desc,
        "ThreadCount" => :desc,
        "TotalStartedThreadCount" => :desc
      }
    end
  
    def initialize(db, fs_ip, application, name, test_type, id, metric_id)
      @average_metric_list = {
        "PeakThreadCount" => [],
        "DaemonThreadCount" => [],
        "ThreadCount" => [],
        "TotalStartedThreadCount" => []
      }
  
      @detailed_metric_list = {
        "PeakThreadCount" => [],
        "DaemonThreadCount" => [],
        "ThreadCount" => [],
        "TotalStartedThreadCount" => []
      }
      super(db, fs_ip, application, name, test_type, id, metric_id)
    end 
  
    def populate_metric(entry, name, id, start, stop)
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
    end
  end
end