require 'htmlentities'
require 'rest-client'

module PluginModule
  module Adapters
    class GraphiteRestAdapter
      attr_reader :remote_field, :remote_metrics, :local_host, :local_user, :local_path, :plugin_id, :store, :local_prefix
      
      def initialize(store, plugin_id, remote, local)
        raise ArgumentError unless remote and local
        @remote_field = remote['field']
        @remote_metrics = remote['metric']
        @local_host = local['server']
        @local_user = local['user']
        @local_path = "#{local['path']}/#{local['prefix']}"
        @local_prefix = local['prefix']
        @plugin_id = plugin_id
        @store = store
      end
      
      def load(guid, prefix, application, sub_app, type, start, stop)
        yield if block_given?
        #first, download from remote
        tmp_dir = "/tmp/#{guid}/data/#{@plugin_id}/"
        FileUtils.mkpath tmp_dir unless File.exists?(tmp_dir)
        
        coder = HTMLEntities.new
        metrics.map {|m| coder.encode(m)}

        
        metrics = @remote_metrics.join('&metric[]=')
        if start.is_a?(Fixnum)
          target_start = DateTime.strptime(start.to_s,"%s").strftime("%H:%M_%Y%m%d")
        else
          target_start = DateTime.parse(start).strftime("%H:%M_%Y%m%d")
        end

        if stop.is_a?(Fixnum)
          target_stop = DateTime.strptime(stop.to_s,"%s").strftime("%H:%M_%Y%m%d")
        else
          target_stop = DateTime.parse(stop).strftime("%H:%M_%Y%m%d")
        end
        
        File.open("#{tmp_dir}/graphitedata.out_#{@remote_host}", 'w') do |f|
          f.write(RestClient.get "http://#{@remote_host}/render/?#{targets}&from=#{target_start}&until=#{target_stop}&format=json")
        end
        
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
end  
