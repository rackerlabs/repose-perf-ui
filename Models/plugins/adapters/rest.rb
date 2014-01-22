require 'rest-client'

module PluginModule
  module Adapters
    class RestAdapter
      attr_reader :remote_host, :remote_uri, :remote_params, :remote_headers, :local_host, :local_user, :local_path, :plugin_id, :store, :local_prefix, :template, :dateformat
      
      def check_format(response, template)
        response.class == template.class
      end
      
      def check_list(hash)
        result = hash.find do |key, value|
          value == false
        end
        result
      end
      
      def check_vs_template(current_template, response, template_name_list)
        if current_template.is_a?(Hash)
          current_template.each do |key, value|
            if template_name_list.include?(key)
              template_name_list[key] = true
            elsif template_name_list.include?(value)
              template_name_list[value] = true
            else
              check_vs_template(value, response, template_name_list)
            end
          end
        elsif current_template.is_a?(Array)
          current_template.each do |id|
            if template_name_list.include?(id)
              template_name_list[id] = true
            else
              check_vs_template(id, response, template_name_list)
            end
          end
        end
      end
      
      def match_vs_template(response)
        check_format(response, @template)
        
        template_name_list = {
          '<METRIC_NAME>' => false, 
          '<DATAPOINT_VALUE>' => false, 
          '<DATAPOINT_TIMESTAMP>' => false
        }
        
        current_template = @template
        
        check_vs_template(current_template, response, template_name_list)
        template_name_list.each {|k,v| raise ArgumentError, "#{k} not set" unless v }
      end
      
      def initialize(store, plugin_id, remote, local)
        raise ArgumentError unless remote and local
        @remote_host = remote['host']
        @remote_uri = remote['uri']
        @remote_params = remote['params']
        @remote_headers = remote['headers']
        @template = remote['template']
        @dateformat = remote['dateformat']
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
        
        dateformat = @dateformat.gsub(/H/,"%H").gsub(/M/,"%M").gsub(/Y/,"%Y").gsub(/m/,"%m").gsub(/d/,"%d")
        
        if start.is_a?(Fixnum)
          target_start = DateTime.strptime(start.to_s,"%s").strftime(dateformat)
        else
          target_start = DateTime.parse(start).strftime(dateformat)
        end

        if stop.is_a?(Fixnum)
          target_stop = DateTime.strptime(stop.to_s,"%s").strftime(dateformat)
        else
          target_stop = DateTime.parse(stop).strftime(dateformat)
        end
        
        remote_uri = @remote_uri.gsub(/<START>/,target_start.to_s).gsub(/<STOP>/,target_stop.to_s)
        remote_params = {:params => JSON.parse(@remote_params)} if @remote_params && !@remote_params.empty? 
        remote_headers = JSON.parse(@remote_headers) if @remote_headers && !@remote_headers.empty? 
        File.open("#{tmp_dir}rest_output.txt_#{@remote_host}", 'w') do |f|
          
          if remote_params && remote_headers
            response = RestClient.get "#{@remote_host}/#{remote_uri}", remote_params , remote_headers
          elsif remote_params
            response = RestClient.get "#{@remote_host}/#{remote_uri}", remote_params
          elsif remote_headers
            response = RestClient.get "#{@remote_host}/#{remote_uri}" , remote_headers
          else
            response = RestClient.get "#{@remote_host}/#{remote_uri}"
          end
          
          #validate that the response matches the template!
          parsed_response = JSON.parse(response)
          f.write(response) if match_vs_template(parsed_response)
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
             "location" => "/#{@local_prefix}/#{application}/#{sub_app}/results/#{type}/#{guid}/data/#{@plugin_id}/#{entry_basename}",
             "template" => @template
          }.to_json
          @store.hset(
            "#{application}:#{sub_app}:results:#{type}:#{guid}:data", "#{@plugin_id}|#{prefix}|#{entry_basename}", plugin) 
        end
        
        FileUtils.rm_rf("/tmp/#{guid}")
      end    
    end
  end
end  
