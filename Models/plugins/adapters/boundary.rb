require 'cgi'
require 'rest-client'

module PluginModule
  module Adapters
    class BoundaryRestAdapter
      attr_reader :remote_field, :remote_metrics, :remote_api, :remote_account, :remote_agent, :local_host, :local_user, :local_path, :plugin_id, :store, :local_prefix

      def initialize(store, plugin_id, remote, local)
        raise ArgumentError unless remote and local
        @remote_field = remote['field']
        @remote_account = remote['account']
        @remote_agent = remote['agent']
        @remote_metrics = remote['metric']
        @remote_api = remote['api-key']
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

        encoded_metrics = @remote_metrics.map {|m| CGI::escape(m)}


        metrics = encoded_metrics.join('&metrics[]=')
        if start.is_a?(Fixnum)
          target_start = DateTime.strptime(start.to_s,"%s").strftime("%Y-%m-%dT%H:%m:%SZ")
        else
          target_start = DateTime.parse(start).strftime("%Y-%m-%dT%H:%m:%SZ")
        end

        if stop.is_a?(Fixnum)
          target_stop = DateTime.strptime(stop.to_s,"%s").strftime("%Y-%m-%dT%H:%m:%SZ")
        else
          target_stop = DateTime.parse(stop).strftime("%Y-%m-%dT%H:%m:%SZ")
        end

        File.open("#{tmp_dir}/boundary.out_#{@remote_field}", 'w') do |f|
          f.write(RestClient.get "https://api.boundary.com/api/v1/accounts/#{@remote_account}/agents/#{@remote_agent}/data.json?metrics[]=#{metrics}&begin=#{target_start}&end=#{target_stop}&field=#{@remote_field}", {"x-api-key" => @remote_api})
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
