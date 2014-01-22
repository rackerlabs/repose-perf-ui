require 'rest-client'

module PluginModule
  module Adapters
    class JenkinsRestAdapter
      attr_reader :remote_host, :remote_job, :remote_build, :local_host, :local_user, :local_path, :plugin_id, :store, :local_prefix
      
      def initialize(store, plugin_id, remote, local)
        raise ArgumentError unless remote and local
        @remote_host = remote['host']
        @remote_job = remote['job']
        @remote_build = remote['build']
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
        
        puts "http://#{@remote_host}/job/#{@remote_job}/#{@remote_build}/api/json?pretty=true"
        
        File.open("#{tmp_dir}/jenkinsdata.out_#{@remote_host}_#{@remote_job}_#{@remote_build}", 'w') do |f|
          f.write(RestClient.get "http://#{@remote_host}/job/#{@remote_job}/#{@remote_build}/api/json?pretty=true")
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
