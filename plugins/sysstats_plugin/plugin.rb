require_relative './../../Models/plugin.rb'
require_relative './../../Models/plugin_results.rb'
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

class SysstatsPlugin < Plugin

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
          :klass => CpuResultStrategy,
          :execution => 'sar -u'
        },
        {
          :id => 'kernel',
          :name => 'Kernel metrics',
          :klass => KernelResultStrategy,
          :execution => 'sar -v'
        },
        {
          :id => 'memory_swap',
          :name => 'Memory Swap metrics',
          :klass => MemorySwapResultStrategy,
          :execution => 'sar -S'
        },
        {
          :id => 'memory_page',
          :name => 'Memory page metrics',
          :klass => MemoryPageResultStrategy,
          :execution => 'sar -R'
        },
        {
          :id => 'memory_utilization',
          :name => 'Memory utilization metrics',
          :klass => MemoryUtilizationResultStrategy,
          :execution => 'sar -r'
        },
        {
          :id => 'tcp_failure_network',
          :name => 'TCP Failure metrics',
          :klass => TcpFailureNetworkResultStrategy,
          :execution => 'sar -n ETCP'
        },
        {
          :id => 'tcp_network',
          :name => 'TCP',
          :klass => TcpNetworkResultStrategy,
          :execution => 'sar -n TCP'
        },
        {
          :id => 'ip_failure_network',
          :name => 'IP Failure metrics',
          :klass => IpFailureNetworkResultStrategy,
          :execution => 'sar -n EIP'
        },
        {
          :id => 'ip_network',
          :name => 'IP metrics',
          :klass => IpNetworkResultStrategy,
          :execution => 'sar -n IP'
        },
        {
          :id => 'device_network',
          :name => 'Device Network metrics',
          :klass => DeviceNetworkResultStrategy,
          :execution => 'sar -n DEV'
        },
        {
          :id => 'device_disk',
          :name => 'Device Disk metrics',
          :klass => DeviceDiskResultStrategy,
          :execution => 'sar -d'
        },
        {
          :id => 'device_failure',
          :name => 'Device Network Failure metrics',
          :klass => DeviceFailureNetworkResultStrategy,
          :execution => 'sar -n EDEV'
        }
      ]
    end
    
    def show_summary_data(application, name, test, id, test_id, options=nil)
      metric = SysstatsPlugin.show_plugin_names.find {|i| i[:id] == id }
      PluginModule::PastPluginResults.format_results(
        PluginModule::PluginResult.new(
          metric[:klass].new(
            @db, @fs_ip, application, name,test.chomp('_test'), test_id
          )
        ).retrieve_average_results, metric[:id].to_sym, {}
      ) if metric
    end


=begin
  show all data and return in a list of hashes
=end
    def show_detailed_data(application, name, test, id, test_id, options=nil)
      metric = SysstatsPlugin.show_plugin_names.find {|i| i[:id] == id }
      PluginModule::PastPluginResults.format_results(
        PluginModule::PluginResult.new(
          metric[:klass].new(
            @db, @fs_ip, application, name, test.chomp('_test'), test_id
          )
        ).retrieve_detailed_results, metric[:id].to_sym, {}
      ) if metric
    end

    def order_by_date(content_instance_list)
      result = {}
      content_instance_list.each do |metric_entry_list| 
        metric_entry_list.each do |entry|
          time = DateTime.strptime(entry[:time].chop.chop.chop,'%s') 
          result[time] = [] unless result[time]
          result[time] << entry[:value] 
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
                  PluginModule::RemoteServerAdapter.new(
                    store, 
                    'sysstats_plugin', 
                    tmp_server, 
                    storage_info).load(
                      json_data['guid'], 
                      'ALL', 
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