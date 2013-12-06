module PluginModule
  class PastPluginResults
  
    def self.format_results(results,metric,temp_results, header_descriptions={})
      if results.length > 0
        temp_results[metric] = {}
        temp_results[metric][:content] = {}
        temp_results[metric][:headers] = results.keys 
        temp_results[metric][:description] = header_descriptions
        results.each do |k,v|
          v.each do |y|
            temp_results[metric][:content][y[:dev_name]] = []
            temp_results[metric][:description][y[:dev_name]] = y[:description]
          end
        end
        results.each do |k,v|
          v.each do |y|
            temp_results[metric][:content][y[:dev_name]] << y[:results]
          end
        end
        temp_results
      end
    end
  end 
  
  class PluginResult
    attr_reader :strategy
  
    def initialize(strategy)
      @strategy = strategy
    end
  
    def retrieve_detailed_results
      @strategy.detailed_metric_list
    end
  
    def retrieve_average_results
      @strategy.average_metric_list
    end
  end
  
  class RemoteServerAdapter
    attr_reader :remote_host, :remote_user, :remote_path, :local_host, :local_user, :local_path, :plugin_id, :store, :local_prefix
    
    def initialize(store, plugin_id, remote, local)
      raise ArgumentError unless remote and local
      @remote_host = remote['server']
      @remote_user = remote['user']
      @remote_path = remote['path']
      @local_host = local['server']
      @local_user = local['user']
      @local_path = "#{local['path']}/#{local['prefix']}"
      @local_prefix = local['prefix']
      @plugin_id = plugin_id
      @store = store
    end
    
    def load(guid, prefix, application, sub_app, type)
      yield if block_given?
      #first, download from remote
      tmp_dir = "/tmp/#{guid}/data/#{@plugin_id}/"
      FileUtils.mkpath tmp_dir unless File.exists?(tmp_dir)
      Net::SCP.download!(
        @remote_host, 
        @remote_user, 
        @remote_path, 
        tmp_dir, 
        {:recursive => true,
          :verbose => :debug}
      ) 
      
      #second, upload to local
      Net::SCP.upload!(
        @local_host, 
        @local_user, 
        "/tmp/#{guid}/", 
        "#{@local_path}/#{application}/#{sub_app}/results/#{type}", 
        {:recursive => true, :verbose => true }
      )
      
      #third, add to redis
      Dir.glob("#{tmp_dir}/**/*") do |entry|
        entry_basename = File.basename(entry)
        plugin = {
           "name" => entry_basename, 
           "location" => "/#{@local_prefix}/#{application}/#{sub_app}/results/#{type}/#{guid}/data/#{@plugin_id}/#{entry_basename}"
        }.to_json
        @store.hset(
          "#{application}:#{sub_app}:results:#{type}:#{guid}:data", "#{@plugin_id}|#{prefix}|#{entry_basename}", plugin) 
      end
      
      FileUtils.rm_rf("/tmp/#{guid}")
    end    
  end
end