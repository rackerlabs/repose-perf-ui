require_relative './../../Models/plugins/plugin.rb'
require_relative './../../Models/plugins/plugin_results.rb'
require_relative './../../Models/plugins/adapters/remote_server.rb'
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

class SysstatsPlugin < PluginModule::Plugin

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
          :klass => SysstatsPluginModule::CpuResultStrategy,
          :execution => 'sar -u',
          :type => :time_series
        },
        {
          :id => 'kernel',
          :name => 'Kernel metrics',
          :klass => SysstatsPluginModule::KernelResultStrategy,
          :execution => 'sar -v',
          :type => :time_series
        },
        {
          :id => 'memory_swap',
          :name => 'Memory Swap metrics',
          :klass => SysstatsPluginModule::MemorySwapResultStrategy,
          :execution => 'sar -S',
          :type => :time_series
        },
        {
          :id => 'memory_page',
          :name => 'Memory page metrics',
          :klass => SysstatsPluginModule::MemoryPageResultStrategy,
          :execution => 'sar -R',
          :type => :time_series
        },
        {
          :id => 'memory_utilization',
          :name => 'Memory utilization metrics',
          :klass => SysstatsPluginModule::MemoryUtilizationResultStrategy,
          :execution => 'sar -r',
          :type => :time_series
        },
        {
          :id => 'tcp_failure_network',
          :name => 'TCP Failure metrics',
          :klass => SysstatsPluginModule::TcpFailureNetworkResultStrategy,
          :execution => 'sar -n ETCP',
          :type => :time_series
        },
        {
          :id => 'tcp_network',
          :name => 'TCP',
          :klass => SysstatsPluginModule::TcpNetworkResultStrategy,
          :execution => 'sar -n TCP',
          :type => :time_series
        },
        {
          :id => 'ip_failure_network',
          :name => 'IP Failure metrics',
          :klass => SysstatsPluginModule::IpFailureNetworkResultStrategy,
          :execution => 'sar -n EIP',
          :type => :time_series
        },
        {
          :id => 'ip_network',
          :name => 'IP metrics',
          :klass => SysstatsPluginModule::IpNetworkResultStrategy,
          :execution => 'sar -n IP',
          :type => :time_series
        },
        {
          :id => 'device_network',
          :name => 'Device Network metrics',
          :klass => SysstatsPluginModule::DeviceNetworkResultStrategy,
          :execution => 'sar -n DEV',
          :type => :time_series
        },
        {
          :id => 'device_disk',
          :name => 'Device Disk metrics',
          :klass => SysstatsPluginModule::DeviceDiskResultStrategy,
          :execution => 'sar -d',
          :type => :time_series
        },
        {
          :id => 'device_failure',
          :name => 'Device Network Failure metrics',
          :klass => SysstatsPluginModule::DeviceFailureNetworkResultStrategy,
          :execution => 'sar -n EDEV',
          :type => :time_series
        }
      ]
    end
    
    def show_summary_data(application, name, test, id, test_id, options=nil)
      metric = SysstatsPlugin.show_plugin_names.find {|i| i[:id] == id }
      results = {}
      if options && options[:application_type] == :comparison
        store = Redis.new(@db)
        #get meta results and either 
        test_id.split('+').each do |guid|
          meta_results = store.hgetall("#{application}:#{name}:results:#{test.chomp('_test')}:#{guid}:meta")
          test_json = JSON.parse(meta_results['test'])
          results.merge!(PluginModule::PastPluginResults.format_results(
            PluginModule::PluginResult.new(
              metric[:klass].new(
                @db, @fs_ip, application, name,test.chomp('_test'), guid, metric[:id]
              )
            ).retrieve_average_results, 
            metric[:id].to_sym, 
            {}, 
            metric[:klass].metric_description,
            metric[:type]
          )) if metric
        end
      else
        results = PluginModule::PastPluginResults.format_results(
          PluginModule::PluginResult.new(
            metric[:klass].new(
              @db, @fs_ip, application, name,test.chomp('_test'), test_id, metric[:id]
            )
          ).retrieve_average_results, 
          metric[:id].to_sym, 
          {}, 
          metric[:klass].metric_description,
          metric[:type]
        ) if metric
      end 
      results
    end


=begin
  show all data and return in a list of hashes
=end
    def show_detailed_data(application, name, test, id, test_id, options=nil)
      metric = ReposeJmxPlugin.show_plugin_names.find {|i| i[:id] == id }
      results = {}
      if options && options[:application_type] == :comparison
        store = Redis.new(@db)
        #get meta results and either 
        test_id.split('+').each do |guid|
          meta_results = store.hgetall("#{application}:#{name}:results:#{test.chomp('_test')}:#{guid}:meta")
          test_json = JSON.parse(meta_results['test'])
          results.merge!(PluginModule::PastPluginResults.format_results(
            PluginModule::PluginResult.new(
              metric[:klass].new(
                @db, @fs_ip, application, name,test.chomp('_test'), guid, metric[:id]
              )
            ).retrieve_detailed_results, 
            metric[:id].to_sym, 
            {}, 
            metric[:klass].metric_description,
            metric[:type]
          )) if metric
        end
      else
        results = PluginModule::PastPluginResults.format_results(
          PluginModule::PluginResult.new(
            metric[:klass].new(
              @db, @fs_ip, application, name,test.chomp('_test'), test_id, metric[:id]
            )
          ).retrieve_detailed_results, 
          metric[:id].to_sym, 
          {}, 
          metric[:klass].metric_description,
          metric[:type]
        ) if metric
      end 
      results
    end

    def order_by_date(content_instance_list)
      result = {}
      content_instance_list.each do |metric_entry_list|
        metric_entry_list.each do |entry|
          result[entry[:time]] = [] unless result[entry[:time]]
          result[entry[:time]] << entry[:value]
        end
      end if content_instance_list
      result
    end

=begin
 1. get request for sysstats.log
 2. ssh into box and execute command passed into the block sar -b -f #{sysstats_file} >> output.txt
 3. upload sysstats file with passed in variable sysstats_plugin|plugin_name|IP redis and save as sysstats_pluginname.out_IP 
=end
    def store_data(application, sub_app, type, json_data, store, start_test_data, end_time, storage_info)
      begin
        #iterate through all valid data and add each file separately (parse out on the server).  
        if json_data.has_key?('plugins')
          plugin_data = json_data['plugins'].find {|p| p['id'] == 'sysstats_plugin'}
          if plugin_data
            plugin_type = plugin_data['type'] ? plugin_data['type'] : 'time_series'
            servers = plugin_data['servers']
            if servers
              servers.each do |server|
                
=begin
  execute 
    Net::SCP.download!(
    @remote_host, 
    @remote_user, 
    @remote_path, 
    tmp_dir, 
    {:recursive => true,
      :verbose => :debug}
  ) 
 
=end
                SysstatsPlugin.show_plugin_names.each do |plugin|
                  tmp_server = {
                    'server' => server['server'],
                    'user' => server['user'],
                    'path' => File.join(File.dirname(server['path']), "sysstats_#{plugin[:id]}.out_#{server['server']}") 
                  }
                  PluginModule::Adapters::RemoteServerAdapter.new(
                    store, 
                    'sysstats_plugin', 
                    tmp_server, 
                    storage_info).load(
                      json_data['guid'], 
                      plugin_type, 
                      application, 
                      sub_app, 
                      type) do
                        Net::SSH.start(server['server'], server['user']) do |ssh|
                          # capture all stderr and stdout output from a remote process
                          ssh.exec!("#{plugin[:execution]} -f #{server['path']} >> #{File.join(File.dirname(server['path']), "sysstats_#{plugin[:id]}.out_#{server['server']}")}")
                        end                      
                      end
                end
              end
            else
              raise ArgumentError, "no server list specified"
            end
          else
            raise ArgumentError, "sysstats_plugin id not found"  
          end
        end
        return nil
      rescue => e
        return {'sysstats_plugin' => e.message}
      end
    end
      

  end
