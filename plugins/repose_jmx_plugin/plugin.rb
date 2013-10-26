require_relative './../../Models/plugin.rb'
require_relative 'filterstrategy.rb'
require_relative 'jvmmetricsstrategy.rb'
require_relative 'jvmmemorystrategy.rb'
require_relative 'jvmthreadstrategy.rb'
require_relative 'garbagecollectionstrategy.rb'

class ReposeJmxPlugin < Plugin
  def self.supported_os_list
    [:linux,:macosx,:windows]
  end

  def self.show_plugin_names
    [
      {
        :id => 'filters',
        :name => 'Filter breakdown',
        :klass => FilterStrategy,
        :type => :time_series
      },
      {
        :id => 'gc',
        :name => 'Garbage Collection',
        :klass => GarbageCollectionStrategy,
        :type => :time_series
      },
      {
        :id => 'jvm_memory',
        :name => 'JVM Memory',
        :klass => JvmMemoryStrategy,
        :type => :time_series
      },
      {
        :id => 'jvm_threads',
        :name => 'JVM Threads',
        :klass => JvmThreadStrategy,
        :type => :time_series
      },
      {
        :id => 'logs',
        :name => 'Repose logs',
        :klass => ReposeLogStrategy,
        :type => :blob
      }
    ]
  end

  def show_summary_data(name, test, id, test_id, options=nil)
    metric = ReposeJmxPlugin.show_plugin_names.find {|i| i[:id] == id }
    Results::PastNetworkResults.format_network(NetworkResult.new(metric[:klass].new(name,test.chomp('_test'), test_id)).retrieve_average_results,metric[:id].to_sym,{})
    end

=begin
	show all data and return in a list of hashes
=end
    def show_detailed_data(name, test, id, test_id, options=nil)
      network = ReposeJmxPlugin.show_plugin_names.find {|i| i[:id] == id }
      Results::PastNetworkResults.format_network(NetworkResult.new(network[:klass].new(name,test.chomp('_test'), test_id)).retrieve_detailed_results,network[:id].to_sym,{})
    end

    def order_by_date(content_instance_list)
      result = {}
      content_instance_list.each do |metric_entry_list| 
        metric_entry_list.each do |entry|
          time = DateTime.strptime(entry[:time].chop.chop.chop,'%s') 
          result[time] = [] unless result[time]
          result[time] << entry[:value] 
        end
      end
      result
    end
end
