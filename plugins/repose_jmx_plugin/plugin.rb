require_relative './../../Models/plugins/plugin.rb'
require_relative './../../Models/plugins/plugin_results.rb'
require_relative './../../Models/plugins/adapters/remote_server.rb'
require_relative 'filterstrategy.rb'
require_relative 'jvmmemorystrategy.rb'
require_relative 'jvmthreadstrategy.rb'
require_relative 'garbagecollectionstrategy.rb'
require_relative 'reposelogstrategy.rb'

class ReposeJmxPlugin < PluginModule::Plugin

  def self.supported_os_list
    [:linux,:macosx,:windows]
  end

  def self.show_plugin_names
    [
      {
        :id => 'filters',
        :name => 'Filter breakdown',
        :klass => ReposeJmxPluginModule::FilterStrategy,
        :type => :time_series
      },
      {
        :id => 'gc',
        :name => 'Garbage Collection',
        :klass => ReposeJmxPluginModule::GarbageCollectionStrategy,
        :type => :time_series
      },
      {
        :id => 'jvm_memory',
        :name => 'JVM Memory',
        :klass => ReposeJmxPluginModule::JvmMemoryStrategy,
        :type => :time_series
      },
      {
        :id => 'jvm_threads',
        :name => 'JVM Threads',
        :klass => ReposeJmxPluginModule::JvmThreadStrategy,
        :type => :time_series
      },
      {
        :id => 'logs',
        :name => 'Repose logs',
        :klass => ReposeJmxPluginModule::ReposeLogStrategy,
        :type => :blob
      }
    ]
  end

  def show_summary_data(application, name, test, id, test_id, options=nil)
    metric = ReposeJmxPlugin.show_plugin_names.find {|i| i[:id] == id }
    results = {}
    if options && options[:application_type] == :comparison
      results[:plugin_type] = metric[:type]
      results[:id_results] = []
      store = Redis.new(@db)
      #get meta results and either
      test_id.split('+').each do |guid|
        meta_results = store.hgetall("#{application}:#{name}:results:#{test.chomp('_test')}:#{guid}:meta")
        test_json = JSON.parse(meta_results['test'])
        if test_json['comparison_guid']
          #get the repose data here
          results[:id_results] << {:id => guid, :results => PluginModule::PastPluginResults.format_results(
            PluginModule::PluginResult.new(
              metric[:klass].new(
                @db, @fs_ip, application, name,test.chomp('_test'), test_json['comparison_guid'], metric[:id]
              )
            ).retrieve_average_results, 
            metric[:id].to_sym, 
            {}, 
            metric[:klass].metric_description,
            metric[:type]
          )} if metric
        end
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

  def show_detailed_data(application, name, test, id, test_id, options=nil)
    metric = ReposeJmxPlugin.show_plugin_names.find {|i| i[:id] == id }
    results = {}
    if options && options[:application_type] == :comparison
      results[:plugin_type] = metric[:type] if metric
      results[:id_results] = []
      store = Redis.new(@db)
      #get meta results and either 
      test_id.split('+').each do |guid|
        meta_results = store.hgetall("#{application}:#{name}:results:#{test.chomp('_test')}:#{guid}:meta")
        test_json = JSON.parse(meta_results['test'])
        if test_json['comparison_guid']
          #get the repose data here
          results[:id_results] << {:id => guid, :results => PluginModule::PastPluginResults.format_results(
            PluginModule::PluginResult.new(
              metric[:klass].new(
                @db, @fs_ip, application, name,test.chomp('_test'), test_json['comparison_guid'], metric[:id]
              )
            ).retrieve_detailed_results, 
            metric[:id].to_sym, 
            {}, 
            metric[:klass].metric_description,
            metric[:type]
          )} if metric
        end
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
          plugin_type = plugin_data['type'] ? plugin_data['type'] : 'time_series'
          servers = plugin_data['servers']
          if servers
            servers.each do |server|
              PluginModule::Adapters::RemoteServerAdapter.new(store, 'repose_jmx_plugin', server, storage_info).load(json_data['guid'], plugin_type, application, sub_app, type)
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
