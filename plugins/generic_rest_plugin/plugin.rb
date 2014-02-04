require_relative './../../Models/plugins/plugin.rb'
require_relative './../../Models/plugins/plugin_results.rb'
require_relative './../../Models/plugins/adapters/rest.rb'
require_relative 'genericresttimeseriesstrategy.rb'

class GenericRestPlugin < PluginModule::Plugin
  
  def self.supported_os_list
    [:linux,:macosx,:windows]
  end

  def self.show_plugin_names
    [
      {
        :id => 'rest_time_series',
        :name => 'Generic Time Series Metrics',
        :klass => GenericRestPluginModule::GenericRestTimeSeriesStrategy,
        :type => :time_series
      }
    ]
  end

  def show_summary_data(application, name, test, id, test_id, options=nil)
    metric = GenericRestPlugin.show_plugin_names.find {|i| i[:id] == id }
    PluginModule::PastPluginResults.format_results(
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

=begin
	show all data and return in a list of hashes
=end
  def show_detailed_data(application, name, test, id, test_id, options=nil)
    metric = GenericRestPlugin.show_plugin_names.find {|i| i[:id] == id }
    PluginModule::PastPluginResults.format_results(
      PluginModule::PluginResult.new(
        metric[:klass].new(
          @db, @fs_ip, application, name, test.chomp('_test'), test_id, metric[:id]
        )
      ).retrieve_detailed_results, 
      metric[:id].to_sym, 
      {}, 
      metric[:klass].metric_description,
      metric[:type]
    ) if metric
  end

  def order_by_date(content_instance_list)
    result = {}
    content_instance_list.each do |metric_entry_list| 
      metric_entry_list.each do |entry|
        time = entry[:time].is_a?(String) ? DateTime.strptime(entry[:time].to_s.chop.chop.chop,'%s') : DateTime.strptime(entry[:time].to_s,'%s') 
        result[time] = [] unless result[time]
        result[time] << entry[:value] 
      end
    end if content_instance_list
    result
  end
  
  def store_data(application, sub_app, type, json_data, store, start_test_data, end_time, storage_info)
    begin
      if json_data.has_key?('plugins')
        plugin_data = json_data['plugins'].find {|p| p['id'] == 'generic_rest_plugin'}
        if plugin_data
          plugin_type = plugin_data['type'] ? plugin_data['type'] : 'time_series'
          servers = plugin_data['servers']
          if servers
            servers.each do |server|
              PluginModule::Adapters::RestAdapter.new(store, 'generic_rest_plugin', server, storage_info).load(json_data['guid'], plugin_type, application, sub_app, type, start_test_data['time'], end_time)
            end
          else
            raise ArgumentError, "no server list specified"
          end
        else
          raise ArgumentError, "generic_rest_plugin id not found"  
        end
      end
      return nil
    rescue => e
      p e.backtrace
      return {'generic_rest_plugin' => e.message}
    end
  end
end