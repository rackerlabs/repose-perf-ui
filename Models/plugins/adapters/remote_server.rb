module PluginModule
  module Adapters
    class RemoteServerAdapter
      attr_reader :remote_host, :remote_user, :remote_path, :local_host, :local_user, :local_path, :plugin_id, :store, :local_prefix
      
      def initialize(store, plugin_id, remote, local)
        raise ArgumentError unless remote and local
        @remote_host = remote['server']
        @remote_user = remote['user']
        @remote_path = remote['path']
        @local_host = local['destination']
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
        
        puts @remote_host, @remote_path, @remote_user
        Net::SCP.download!(
          @remote_host, 
          @remote_user, 
          @remote_path, 
          tmp_dir, 
          {:recursive => true,
            :verbose => :debug}
        ) 
        
        puts "downloaded"
        Dir.glob("#{tmp_dir}**/*").each do |f|
          `mv #{f} #{f}_#{@remote_host}`
        end
        
        puts @local_host, @local_path, @local_user
        #second, upload to local
        if @local_host == 'localhost'
          FileUtils.mkpath "#{@local_path}/#{application}/#{sub_app}/results/#{type}" unless File.exists?("#{@localhost_path}/#{application}/#{sub_app}/results/#{type}")
          FileUtils.cp_r "/tmp/#{guid}/", "#{@local_path}/#{application}/#{sub_app}/results/#{type}/"
        else
          Net::SCP.upload!(
            @local_host, 
            @local_user, 
            "/tmp/#{guid}/", 
            "#{@local_path}/#{application}/#{sub_app}/results/#{type}", 
            {:recursive => true, :verbose => true }
          )
        end
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
