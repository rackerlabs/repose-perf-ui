require_relative './../../Models/plugin.rb'
require_relative './../../Models/plugin_results.rb'
require_relative 'filterstrategy.rb'
require_relative 'jvmmemorystrategy.rb'
require_relative 'jvmthreadstrategy.rb'
require_relative 'garbagecollectionstrategy.rb'
require_relative 'reposelogstrategy.rb'

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

  def show_summary_data(application, name, test, id, test_id, options=nil)
    metric = ReposeJmxPlugin.show_plugin_names.find {|i| i[:id] == id }
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
    metric = ReposeJmxPlugin.show_plugin_names.find {|i| i[:id] == id }
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
  
  def store_data(application, sub_app, type, json_data, store, start_test_data, end_time, storage_info)
    begin
      if json_data.has_key?('plugins')
        plugin_data = json_data['plugins'].find {|p| p['id'] == 'repose_jmx_plugin'}
        if plugin_data
          servers = plugin_data['servers']
          if servers
            servers.each do |server|
              PluginModule::RemoteServerAdapter.new(store, 'repose_jmx_plugin', server, storage_info).load(json_data['guid'], 'ALL', application, sub_app, type)
            end
          else
            raise ArgumentError, "no server list specified"
          end
        else
          raise ArgumentError, "repose_jmx_plugin id not found"  
        end
      end
      return nil
    rescue => e
      return {'repose_jmx_plugin' => e.message}
    end
  end

end
