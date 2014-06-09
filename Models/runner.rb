require 'net/scp'
require 'open-uri'
require 'json'

module SnapshotComparer
module Models
  class JMeterRunner
    def compile_summary_results(test_hash, guid, entry)
      temp_hash = {}
      summary_list = open(entry) do |f|
        f.readlines[-5..-1]
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
        puts "time line: #{time_line.inspect}"
        range_entry = line.scan(/summary \+\s+(\d+)\s+in\s+(\d+(?:\.\d)?)s =\s+(\d+(?:\.\d)?)\/s Avg:\s+(\d+).*Err:\s+(\d+)/)
        puts "t: #{range_entry.inspect}"
        unless range_entry.empty?
          avg = range_entry[0][3].to_i
          errors = range_entry[0][4].to_i
          puts "set avg, errors: #{range_entry[0][3]}, #{range_entry[0][4]}"
        end
        unless time_line.empty?
          total_throughput = time_line[0][0].to_i
          current_time = time_line[0][1].to_i
          puts "(#{total_throughput} - #{prev_throughput}) / (#{current_time} - #{prev_time})"
          actual_throughput = (total_throughput - prev_throughput) / (current_time - prev_time) if current_time - prev_time > 0
          prev_time = current_time
          prev_throughput = total_throughput
          puts "set throughput, time range, temp time: #{actual_throughput}, #{current_time}"
        end
        puts "throughput: #{actual_throughput}, #{avg}, #{errors}, #{current_time}"
        if actual_throughput.to_i > 0 && current_time.to_i > 0
          detailed_results << DetailedResult.new(current_time, actual_throughput, avg, errors)
          current_time, actual_throughput, avg, errors = 0
        end
      end
      detailed_results
    end

    def store_results(application, sub_app, type, guid, source_result_info, storage_info, store)
=begin
 1. get file remotely (specified by configs whether it's an scp or wget)
 2. load file in specific directory via scp
=end
      FileUtils.mkdir_p "/tmp/#{guid}/data/"
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
      puts "testers"
      summary_results = compile_summary_results({}, guid, "/tmp/#{guid}/data/summary.log")
      puts summary_results
    end
  end

	class GatlingRunner
	end

	class FloodRunner
	end

	class AutoBenchRunner
	end
end
end
