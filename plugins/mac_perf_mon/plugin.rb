require_relative './../../Models/plugin.rb'
class MacOsxPlugin < Plugin

  def self.supported_os_list
    [:macosx]
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
          :class => CpuResultStrategy.new
        },
        {
          :id => 'kernel',
          :name => 'Kernel metrics',
          :class => KernelResultStrategy.new
        },
        {
          :id => 'memory_swap',
          :name => 'Memory Swap metrics',
          :class => MemorySwapResultStrategy.new
        },
        {
          :id => 'memory_page',
          :name => 'Memory page metrics',
          :class => MemoryPageResultStrategy.new
        },
        {
          :id => 'memory_utilization',
          :name => 'Memory utilization metrics',
          :class => MemoryUtilizationResultStrategy.new
        },
        {
          :id => 'tcp_failure_network',
          :name => 'TCP Failure metrics',
          :class => TcpFailureNetworkResultStrategy.new
        },
        {
          :id => 'tcp_network',
          :name => 'TCP',
          :class => TcpNetworkResultStrategy.new
        },
        {
          :id => 'ip_failure_network',
          :name => 'IP Failure metrics',
          :class => IpFailureNetworkResultStrategy.new
        },
        {
          :id => 'ip_network',
          :name => 'IP metrics',
          :class => IpNetworkResultStrategy.new
        },
        {
          :id => 'device_network',
          :name => 'Device Network metrics',
          :class => DeviceNetworkResultStrategy.new
        },
      ]
  end

  def show_summary_data(name, test, id, test_id)
      network = show_plugin_names.find {|id| id[:id] == id }
      Results::PastNetworkResults.format_network(NetworkResult.new(network[:class].populate_metric(name,test.chomp('_test'), test_id)).retrieve_average_results,network[:id].to_sym,[])
  end

=begin
	show all data and return in a list of hashes
=end
  def show_detailed_data
  end
end
