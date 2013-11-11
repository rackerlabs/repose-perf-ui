require_relative './../../Models/plugin.rb'
require_relative 'results.rb'
require_relative 'cpuresultstrategy.rb'
require_relative 'kernelresultstrategy.rb'
require_relative 'devicediskresultstrategy.rb'
require_relative 'devicenetworkresultstrategy.rb'
require_relative 'devicefailurenetworkresultstrategy.rb'
require_relative 'memoryswapresultstrategy.rb'
require_relative 'memorypageresultstrategy.rb'
require_relative 'memoryutilsresultstrategy.rb'
require_relative 'tcpfailurenetworkresultstrategy.rb'
require_relative 'tcpnetworkresultstrategy.rb'
require_relative 'ipfailurenetworkresultstrategy.rb'
require_relative 'ipnetworkresultstrategy.rb'

class UbuntuPerfmonPlugin < Plugin

    def self.supported_os_list
      [:linux]
    end
=begin
	parse data will be called on every collection to load data from 
=end
    def parse_data
    end

=begin
  	show only summary data (average, min, max, 90%)
=end
    def self.show_plugin_names
      [
        {
          :id => 'cpu',
          :name => 'CPU metrics',
          :klass => CpuResultStrategy
        },
        {
          :id => 'kernel',
          :name => 'Kernel metrics',
          :klass => KernelResultStrategy
        },
        {
          :id => 'memory_swap',
          :name => 'Memory Swap metrics',
          :klass => MemorySwapResultStrategy
        },
        {
          :id => 'memory_page',
          :name => 'Memory page metrics',
          :klass => MemoryPageResultStrategy
        },
        {
          :id => 'memory_utilization',
          :name => 'Memory utilization metrics',
          :klass => MemoryUtilizationResultStrategy
        },
        {
          :id => 'tcp_failure_network',
          :name => 'TCP Failure metrics',
          :klass => TcpFailureNetworkResultStrategy
        },
        {
          :id => 'tcp_network',
          :name => 'TCP',
          :klass => TcpNetworkResultStrategy
        },
        {
          :id => 'ip_failure_network',
          :name => 'IP Failure metrics',
          :klass => IpFailureNetworkResultStrategy
        },
        {
          :id => 'ip_network',
          :name => 'IP metrics',
          :klass => IpNetworkResultStrategy
        },
        {
          :id => 'device_network',
          :name => 'Device Network metrics',
          :klass => DeviceNetworkResultStrategy
        },
        {
          :id => 'device_disk',
          :name => 'Device Disk metrics',
          :klass => DeviceDiskResultStrategy
        },
        {
          :id => 'device_failure',
          :name => 'Device Network Failure metrics',
          :klass => DeviceFailureNetworkResultStrategy
        }
      ]
    end

    def show_summary_data(app, application, name, test, id, test_id, options=nil)
      network_strategy = UbuntuPerfmonPlugin.show_plugin_names.find {|i| i[:id] == id }
      store = Redis.new(app.db)
      #get meta results and either 
      meta_results = store.hgetall("#{application}:#{name}:results:#{test_type}:#{id}:meta")
      test_json = JSON.parse(meta_results['test'])
      
      if application_type == :comparison
        first_result = retrieve_average_results(app, application, name, test, test_id, test_json, id, network_strategy)
        guid = test_json['comparison_guid']
        second_result = retrieve_average_results(app, application, name, test, guid, test_json, id, network_strategy)
        first_result.zip(second_result)
      else
        retrieve_average_results(app, application, name, test, test_id, id, network_strategy)
      end
    end

=begin
	show all data and return in a list of hashes
=end
    def show_detailed_data(name, test, id, test_id, options=nil)
      network_strategy = UbuntuPerfmonPlugin.show_plugin_names.find {|i| i[:id] == id }
      PastNetworkResults.format_network(
        NetworkResult.new(
          network_strategy[:klass].new(
            application,
            name,
            test.chomp('_test'), 
            test_id
          )
        ).retrieve_detailed_results,
        network_strategy[:id].to_sym,
        {}
      )
    end

    def order_by_date(content_instance_list)
      result = {}
      content_instance_list.each do |metric_entry_list| 
        metric_entry_list.each do |entry| 
          result[entry[:time]] = [] unless result[entry[:time]]
          result[entry[:time]] << entry[:value] 
        end
      end
      result
    end

    def store_data(start_time,end_time)
      #this is where the data will be loaded
      #TODO: set up an adapter (either scp, local file store, rest api, DB) and pull data according to timestamps.  Save in Redis
      #redis will zip data up and store it in app_plugin_start_end key and zipped value.  Maybe should be Mongo instead or Riak?
    end
    
    def retrieve_average_results(app, application, name, test, test_id, test_json, plugin_id, network_strategy)
      PastNetworkResults.format_network(
          NetworkResult.new(
            network_strategy[:klass].new(
              app,
              application, 
              name,
              test.chomp('_test'), 
              test_id,
              test_json,
              plugin_id
            )
          ).retrieve_average_results,
          network_strategy[:id].to_sym,
          {},
          network_strategy[:klass].metric_description
        )
    end
  end
