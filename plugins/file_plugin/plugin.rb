require_relative './../../Models/plugins/plugin.rb'
require_relative './../../Models/plugins/plugin_results.rb'
require_relative './../../Models/plugins/adapters/remote_server.rb'
require_relative 'fileblobstrategy.rb'

class FilePlugin < PluginModule::Plugin
  
  def self.supported_os_list
    [:linux,:macosx,:windows]
  end

  def self.show_plugin_names
    [
      {
        :id => 'file',
        :name => 'File Metrics',
        :klass => FilePluginModule::FileBlobStrategy,
        :type => :blob
      }
    ]
  end

  def show_summary_data(application, name, test, id, test_id, options=nil)
    #TODO: this is unique to jenkins logic.  Right now, it should simply show jenkins JSON result (2 if comparison).  
    #TODO: Only summary data since there are no real details
    metric = FilePlugin.show_plugin_names.find {|i| i[:id] == id }
    results = {}
    if metric
      store = Redis.new(@db)
      if options && options[:application_type] == :comparison
        results[:plugin_type] = metric[:type]
        results[:id_results] = []
        if metric[:type] == :blob
          test_id.split('+').each do |guid|
            meta_results = store.hgetall("#{application}:#{name}:results:#{test.chomp('_test')}:#{guid}:meta")
            if meta_results && !meta_results.empty?
              test_json = JSON.parse(meta_results['test'])
              results[:id_results] << {:id => guid, :results => PluginModule::PastPluginResults.format_results(
                PluginModule::PluginResult.new(
                  metric[:klass].new(
                    @db, @fs_ip, application, name,test.chomp('_test'), guid, metric[:id]
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
=begin
          results[:id_results] = []
          store = Redis.new(@db)
          #get meta results and either 
          test_id.split('+').each do |guid|
            meta_results = store.hgetall("#{application}:#{name}:results:#{test.chomp('_test')}:#{guid}:meta")
            if meta_results && !meta_results.empty?
              test_json = JSON.parse(meta_results['test'])
              results[:id_results] << {:id => guid, :results => PluginModule::PastPluginResults.format_results(
                PluginModule::PluginResult.new(
                  metric[:klass].new(
                    @db, @fs_ip, application, name,test.chomp('_test'), guid, metric[:id]
                  )
                ).retrieve_average_results, 
                metric[:id].to_sym, 
                {}, 
                metric[:klass].metric_description,
                metric[:type]
              )} if metric
            end
          end
=end          
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
  end

  def show_detailed_data(application, name, test, id, test_id, options=nil)
  end

  def order_by_date(content_instance_list)
  end
  
  def store_data(application, sub_app, type, json_data, store, start_test_data, end_time, storage_info)
    begin
      if json_data.has_key?('plugins')
        plugin_data = json_data['plugins'].find {|p| p['id'] == 'jenkins_rest_plugin'}
        if plugin_data
          plugin_type = plugin_data['type'] ? plugin_data['type'] : 'time_series'
          servers = plugin_data['servers']
          if servers
            servers.each do |server|
              PluginModule::Adapters::JenkinsRestAdapter.new(store, 'jenkins_rest_plugin', server, storage_info).load(json_data['guid'], plugin_type, application, sub_app, type)
            end
          else
            raise ArgumentError, "no server list specified"
          end
        else
          raise ArgumentError, "jenkins_rest_plugin id not found"  
        end
      end
      return nil
    rescue => e
      p e.backtrace
      return {'jenkins_rest_plugin' => e.message}
    end
  end
end