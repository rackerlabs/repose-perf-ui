require 'net/scp'
require 'open-uri'
require 'json'
require_relative 'database.rb'
require_relative 'sla.rb'
require_relative 'notification.rb'
require_relative 'result.rb'
require_relative 'application_test_type.rb'
require_relative '../apps/bootstrap.rb'

module SnapshotComparer
module Models
  class JMeterRunner
    attr_reader :app_list
    attr_accessor :notification_validation_results

    def initialize(app_list = nil)
      if app_list
        @app_list = app_list
      else
        @app_list = SnapshotComparer::Apps::Bootstrap.application_list 
      end
    end

    def compile_summary_results(test_hash, guid, entry)
      temp_hash = {}
      begin
        summary_list = open(entry) do |f|
          f.readlines[-5..-1]
        end
      rescue => e
        puts e
        puts e.backtrace 
      end
      summary_list.each do |summary|
        summary.scan(/summary =\s+\d+\s+in\s+(\d+(?:\.\d)?)s =\s+(\d+(?:\.\d)?)\/s Avg:\s+(\d+).*Err:\s+(\d+)/).map do |time_offset,throughput,average,errors|
          temp_hash[:length] = time_offset
          temp_hash[:throughput] = throughput
          temp_hash[:average] = average
          temp_hash[:errors] = errors
        end
      end if summary_list
=begin
      if temp_hash[:length].nil?
        summary = `tail -1 #{summary_location}`
        summary.scan(/summary =\s+\d+\s+in\s+(\d+(?:\.\d)?)s =\s+(\d+(?:\.\d)?)\/s Avg:\s+(\d+).*Err:\s+(\d+)/).map do |time_offset,throughput,average,errors|
          temp_hash[:length] = time_offset
          temp_hash[:throughput] = throughput
          temp_hash[:average] = average
          temp_hash[:errors] = errors
        end
      end
=end
      test_hash.merge!(temp_hash)
      test_hash
    end

    def compile_detailed_results(guid, entry)
      detailed_results = []
      actual_throughput = 0
      prev_throughput = 0
      current_time = 0
      prev_time = 0
      avg = 0
      errors = 0
      open(entry).readlines.each do |line|
        time_line = line.scan(/summary \=\s+(\d+)\s+in\s+(\d+(?:\.\d)?)s/)
        range_entry = line.scan(/summary \+\s+(\d+)\s+in\s+(\d+(?:\.\d)?)s =\s+(\d+(?:\.\d)?)\/s Avg:\s+(\d+).*Err:\s+(\d+)/)
        unless range_entry.empty?
          avg = range_entry[0][3].to_i
          errors = range_entry[0][4].to_i
        end
        unless time_line.empty?
          total_throughput = time_line[0][0].to_i
          current_time = time_line[0][1].to_i
          actual_throughput = (total_throughput - prev_throughput) / (current_time - prev_time) if current_time - prev_time > 0
          prev_time = current_time
          prev_throughput = total_throughput
        end
        if actual_throughput.to_i > 0 && current_time.to_i > 0
          detailed_results << DetailedResult.new(current_time, actual_throughput, avg, errors)
          current_time, actual_throughput, avg, errors = 0
        end
      end
      detailed_results
    end

    def store_results(application, sub_app, type, guid, source_result_info, storage_info, store, config = File.expand_path("config/config.yaml", Dir.pwd), comparison_guid = nil)
=begin
 1. get file remotely (specified by configs whether it's an scp or wget)
 2. load file in specific directory via scp
=end
      FileUtils.mkdir_p "/tmp/#{guid}/data/"
      puts "#{DateTime.now}: source result info: #{source_result_info}"
      if source_result_info['server'] == 'localhost'
        FileUtils.mkpath "#{storage_info['prefix']}/#{application}/#{sub_app}/results/#{type}" unless File.exists?("#{storage_info['prefix']}/#{application}/#{sub_app}/results/#{type}")
        FileUtils.cp_r source_result_info['path'], "/tmp/#{guid}/data/summary.log"
      else
        Net::SCP.download!(
          source_result_info['server'],
          source_result_info['user'],
          source_result_info['path'],
          "/tmp/#{guid}/data/summary.log")
      end
  
      result_data = {}
      result_data['location'] = "/#{storage_info['prefix']}/#{application}/#{sub_app}/results/#{type}/#{guid}/data/summary.log"
      result_data['name'] = 'summary.log'

      result = result_data.to_json
      store.hset("#{application}:#{sub_app}:results:#{type}:#{guid}:data", "results", result)

=begin
  Here, check to see if notifications are set then check if it needs to be sent
  - compile summary results and save to pg (required)
  - compare sla to results and send notification (if set)
=end
      summary_results = {}
      compile_summary_results(summary_results, guid, "/tmp/#{guid}/data/summary.log")
      database = SnapshotComparer::Models::PostgresDatabase.new
      if config['database'] && Database.databases[config['database']['type'].to_sym]
        database = Database.databases[config['database']['type'].to_sym]
      end
      #database.store_metrics_for_test(application, sub_app, type, guid, summary_results)

=begin
  here, check to see if app type is comparison vs singular 
  if singular, check the notification
  if comparison, check that both tests have finished and perform logic that compares the two
            comparison_guid = test_json['comparison_guid']

            #if comparison guid exists, join the two values and add to overhead list.  Results to compare will always be the variable call.
            #comparison_guid will always be on the control test
            if comparison_guid
              result_to_compare = temp_list.find {|t| t.id == comparison_guid }
              overhead_test_list << Result.new(
                result_to_compare.start,
                result_to_compare.length.to_i - temp.length.to_i,
                result_to_compare.avg.to_f - temp.avg.to_f,
                result_to_compare.throughput.to_f - temp.throughput.to_f,
                result_to_compare.errors.to_i - temp.errors.to_i,
                result_to_compare.name,
                result_to_compare.description,
                "#{result_to_compare.id}+#{temp.id}")
              temp_list.delete(result_to_compare)
            else
              temp_list << temp
            end

=end    
      link_to_result = nil 
      guid_to_save = ""
      app_config = @app_list.find {|a| a[:id] == application}[:klass].new.config
      if app_config['application']['type'].to_sym == :comparison && comparison_guid
# both sides ran
# get comparison guid here and retrive its results
        comparison_results = {}
        comparison_data_results = store.hget("#{application}:#{sub_app}:results:#{type}:#{comparison_guid}:data", "results")
        comparison_summary_data = JSON.parse(comparison_data_results)['location']
        compile_summary_results(comparison_results, comparison_guid, "#{config['scheme']}#{config['file_store']}#{comparison_summary_data}")
        guid_to_save = "#{comparison_guid}+#{guid}"
        link_to_result = "You can check out the results at #{config['ui_scheme']}#{config['ui_hostname']}/#{application}/results/#{sub_app}/#{type}_test/id/#{guid_to_save}"
        overhead_result = SnapshotComparer::Models::Result.get_overhead(comparison_results, summary_results)  
      elsif app_config['application']['type'].to_sym == :singular
# only one side ran but that's ok
        overhead_result = summary_results
        guid_to_save = guid
        link_to_result = "You can check out the results at #{config['ui_scheme']}#{config['ui_hostname']}/#{application}/results/#{sub_app}/#{type}_test/id/#{guid}"
      else       
# we got nothing .  return nil FOR NOW
        overhead_result = nil
      end

      if overhead_result
        sla_list = []
        app_config['application']['sla'].each do | sla |
          sla.each { |sla_key, sla_value| sla_list << SnapshotComparer::Models::Sla.new(sla_key, sla_value['value'],sla_value['limit'].to_sym, sla_value['value_type'], sla_value['test_type'])}
        end
# check if notification is set, send an email
# compare sla list to results in summary_results
        if app_config['application']['notify']
          @notification_validation_results = []
          sla_list.each do |sla|
            puts "#{DateTime.now}: sla: #{sla.inspect}"
            result = SnapshotComparer::Models::Sla.result_failed_sla(sla,overhead_result[sla.name.to_sym], type) if overhead_result.has_key?(sla.name.to_sym) 
            puts "#{DateTime.now}: result: #{result}" 
            @notification_validation_results << result if result
          end

          if !@notification_validation_results.empty?
            @notification_validation_results << link_to_result
            puts "#{DateTime.now}: notification: #{@notification_validation_results}"
            notification = SnapshotComparer::Models::Notification.notifications[app_config['application']['notification']['type'].to_sym]
            notification.new(app_config['application']['notification']['recipient_list'], "SLA failed for #{application} #{sub_app} #{type} test", @notification_validation_results).send_notification
            SnapshotComparer::Models::ApplicationTestType.new(store).save(application, sub_app, type, guid_to_save, SnapshotComparer::Models::ApplicationTestType.FAILED)
          else
            SnapshotComparer::Models::ApplicationTestType.new(store).save(application, sub_app, type, guid_to_save, SnapshotComparer::Models::ApplicationTestType.PASSED)
          end
        end
      end           
    end
  end

  class GatlingRunner
    attr_reader :app_list
    attr_accessor :notification_validation_results

    def initialize(app_list = nil)
      if app_list
        @app_list = app_list
      else
        @app_list = SnapshotComparer::Apps::Bootstrap.application_list 
      end
    end

    def compile_summary_results(test_hash, guid, entry)
      temp_hash = {}
      puts "#{DateTime.now}: compile summary results: #{entry}"
      result_list = []
      request_time_list = []
      begin
        summary_list = open(entry) do |f|
          f.each_line do | line |
            request_time = line.scan(/.*Send Request\t(\d+)/).collect {|request| request[0].to_i }
            request_time_list << request_time[0] unless request_time.empty?
            result = line.scan(/.*Send Request\t(\d+)\t\d+\t\d+\t(\d+)\t(\w+)/).collect {|start_time, end_time, status| {"response" => end_time.to_i - start_time.to_i, "status" => status } }
            result_list << result[0] unless result.empty?
          end
        end
        #puts "result list: #{result_list} and request time list: #{request_time_list}"
        puts "#{DateTime.now}: request time list: #{request_time_list.length} and length: #{request_time_list.max - request_time_list.min}" 
        temp_hash[:length] = (request_time_list.max - request_time_list.min).to_i / 1000
        temp_hash[:throughput] = (request_time_list.length / temp_hash[:length]).to_f
        temp_hash[:average] = result_list.collect {|result| result["response"].to_i }.reduce(:+).to_f / result_list.length
        temp_hash[:errors] = result_list.find_all {|result| result["status"] != "OK" }.size

        test_hash.merge!(temp_hash)
      rescue => e
        puts e
        puts e.backtrace 
      end
      test_hash
    end

    def compile_detailed_results(guid, entry)
      detailed_results = []
      actual_throughput = 0
      prev_throughput = 0
      current_time = 0
      prev_time = 0
      avg = 0
      errors = 0
      open(entry).readlines.each do |line|
        time_line = line.scan(/summary \=\s+(\d+)\s+in\s+(\d+(?:\.\d)?)s/)
        range_entry = line.scan(/summary \+\s+(\d+)\s+in\s+(\d+(?:\.\d)?)s =\s+(\d+(?:\.\d)?)\/s Avg:\s+(\d+).*Err:\s+(\d+)/)
        unless range_entry.empty?
          avg = range_entry[0][3].to_i
          errors = range_entry[0][4].to_i
        end
        unless time_line.empty?
          total_throughput = time_line[0][0].to_i
          current_time = time_line[0][1].to_i
          actual_throughput = (total_throughput - prev_throughput) / (current_time - prev_time) if current_time - prev_time > 0
          prev_time = current_time
          prev_throughput = total_throughput
        end
        if actual_throughput.to_i > 0 && current_time.to_i > 0
          detailed_results << DetailedResult.new(current_time, actual_throughput, avg, errors)
          current_time, actual_throughput, avg, errors = 0
        end
      end
      detailed_results
    end

    def store_results(application, sub_app, type, guid, source_result_info, storage_info, store, config = File.expand_path("config/config.yaml", Dir.pwd), comparison_guid = nil)
=begin
 1. get file remotely (specified by configs whether it's an scp or wget)
 2. load file in specific directory via scp
=end
      # this also needs to download /root/gatling/gatling-charts-highcharts-bundle-2.1.3/results/output/summary.log
      # this needs to download /root/gatling/gatling-charts-highcharts-bundle-2.1.3/results/*/simulation.log
      tmp_dir = "/tmp/#{guid}/data/"
      FileUtils.mkdir_p tmp_dir
      puts "#{DateTime.now}: source result info: #{source_result_info} and guid: #{guid} and did we create it? #{File.directory?(tmp_dir)}"
      puts "#{DateTime.now}: Comparison guid: #{comparison_guid}"
      if source_result_info['server'] == 'localhost'
        FileUtils.mkpath "#{storage_info['prefix']}/#{application}/#{sub_app}/results/#{type}" unless File.exists?("#{storage_info['prefix']}/#{application}/#{sub_app}/results/#{type}")
        FileUtils.cp_r source_result_info['path'], "#{tmp_dir}summary.log"
      else
        Net::SCP.download!(
          source_result_info['server'],
          source_result_info['user'],
          source_result_info['path'],
          tmp_dir,
          :ssh => { :password => source_result_info['password']}, 
          :recursive => true )
      end
      puts "#{DateTime.now}: Temporary directory: #{Dir.glob(File.join(tmp_dir,'**','*.*'))}"
  
      result_data = {}
      result_data['location'] = "/#{storage_info['prefix']}/#{application}/#{sub_app}/results/#{type}/#{guid}/data/summary.log"
      result_data['name'] = 'summary.log'

      result = result_data.to_json
      store.hset("#{application}:#{sub_app}:results:#{type}:#{guid}:data", "results", result)

=begin
  Here, check to see if notifications are set then check if it needs to be sent
  - compile summary results and save to pg (required)
  - compare sla to results and send notification (if set)
=end
      summary_results = {}
=begin
  I just copied over the directory into tmp_dir.  Iterate through and get the first simulation.log. also, save the summary log
=end
      simulation_log = Dir.glob(File.join(tmp_dir, "**", "*.log"))[0]
      puts "#{DateTime.now}: simulation log: #{simulation_log.inspect}"
  
      compile_summary_results(summary_results, guid, simulation_log) if simulation_log
      database = SnapshotComparer::Models::PostgresDatabase.new
      if config['database'] && Database.databases[config['database']['type'].to_sym]
        database = Database.databases[config['database']['type'].to_sym]
      end
      #database.store_metrics_for_test(application, sub_app, type, guid, summary_results)

=begin
  here, check to see if app type is comparison vs singular 
  if singular, check the notification
  if comparison, check that both tests have finished and perform logic that compares the two
            comparison_guid = test_json['comparison_guid']

            #if comparison guid exists, join the two values and add to overhead list.  Results to compare will always be the variable call.
            #comparison_guid will always be on the control test
            if comparison_guid
              result_to_compare = temp_list.find {|t| t.id == comparison_guid }
              overhead_test_list << Result.new(
                result_to_compare.start,
                result_to_compare.length.to_i - temp.length.to_i,
                result_to_compare.avg.to_f - temp.avg.to_f,
                result_to_compare.throughput.to_f - temp.throughput.to_f,
                result_to_compare.errors.to_i - temp.errors.to_i,
                result_to_compare.name,
                result_to_compare.description,
                "#{result_to_compare.id}+#{temp.id}")
              temp_list.delete(result_to_compare)
            else
              temp_list << temp
            end

=end    
      link_to_result = nil 
      guid_to_save = ""
      app_config = @app_list.find {|a| a[:id] == application}[:klass].new.config
      puts "#{DateTime.now}: app config: #{app_config}"
      if app_config['application']['type'].to_sym == :comparison && comparison_guid
# both sides ran
# get comparison guid here and retrive its results
        comparison_results = {}
        comparison_data_results = store.hget("#{application}:#{sub_app}:results:#{type}:#{comparison_guid}:data", "results")
        comparison_summary_data = JSON.parse(comparison_data_results)['location']
        compile_summary_results(comparison_results, comparison_guid, "#{config['scheme']}#{config['file_store']}#{comparison_summary_data}")
        guid_to_save = "#{comparison_guid}+#{guid}"
        link_to_result = "You can check out the results at #{config['ui_scheme']}#{config['ui_hostname']}/#{application}/results/#{sub_app}/#{type}_test/id/#{guid_to_save}"
        overhead_result = SnapshotComparer::Models::Result.get_overhead(comparison_results, summary_results)  
      elsif app_config['application']['type'].to_sym == :singular
# only one side ran but that's ok
        overhead_result = summary_results
        guid_to_save = guid
        link_to_result = "You can check out the results at #{config['ui_scheme']}#{config['ui_hostname']}/#{application}/results/#{sub_app}/#{type}_test/id/#{guid}"
      else       
# we got nothing .  return nil FOR NOW
        overhead_result = nil
      end

      if overhead_result
        sla_list = []
        app_config['application']['sla'].each do | sla |
          sla.each { |sla_key, sla_value| sla_list << SnapshotComparer::Models::Sla.new(sla_key, sla_value['value'],sla_value['limit'].to_sym, sla_value['value_type'], sla_value['test_type'])}
        end
# check if notification is set, send an email
# compare sla list to results in summary_results
        if app_config['application']['notify']
          @notification_validation_results = []
          sla_list.each do |sla|
            puts "#{DateTime.now}: sla: #{sla.inspect}"
            result = SnapshotComparer::Models::Sla.result_failed_sla(sla,overhead_result[sla.name.to_sym], type) if overhead_result.has_key?(sla.name.to_sym) 
            puts "#{DateTime.now}: result: #{result}" 
            @notification_validation_results << result if result
          end

          if !@notification_validation_results.empty?
            @notification_validation_results << link_to_result
            puts "#{DateTime.now}: notification: #{@notification_validation_results}"
            notification = SnapshotComparer::Models::Notification.notifications[app_config['application']['notification']['type'].to_sym]
            notification.new(app_config['application']['notification']['recipient_list'], "SLA failed for #{application} #{sub_app} #{type} test", @notification_validation_results).send_notification
            SnapshotComparer::Models::ApplicationTestType.new(store).save(application, sub_app, type, guid_to_save, SnapshotComparer::Models::ApplicationTestType.FAILED)
          else
            SnapshotComparer::Models::ApplicationTestType.new(store).save(application, sub_app, type, guid_to_save, SnapshotComparer::Models::ApplicationTestType.PASSED)
          end
        end
      end           
    end
	end

	class FloodRunner
	end

	class AutoBenchRunner
	end
end
end
