require 'net/scp'
require 'open-uri'

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
      end
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
      temp_time = 0
      open(entry).readlines.each do |line|
        time_line = line.scan(/summary \=\s+\d+\s+in\s+(\d+(?:\.\d)?)s/)
        t = line.scan(/summary \+\s+\d+\s+in\s+(\d+(?:\.\d)?)s =\s+(\d+(?:\.\d)?)\/s Avg:\s+(\d+).*Err:\s+(\d+)/)
        temp_time = time_line[0][0].to_i unless time_line.empty?
        detailed_results << DetailedResult.new(temp_time, t[0][1], t[0][2], t[0][3]) unless t.empty?
      end
      detailed_results
    end

    def store_results(application, sub_app, type, guid, source_result_info, storage_info, store)
=begin
 1. get file remotely (specified by configs whether it's an scp or wget)
 2. load file in specific directory via scp
=end
      FileUtils.mkdir_p "/tmp/#{guid}/data/"
      #if source_result_info['server'] == 'localhost'
        Net::SCP.download!(
          source_result_info['server'],
          source_result_info['user'],
          source_result_info['path'],
          "/tmp/#{guid}/data/summary.log")

          result_data = {}
          result_data['location'] = "/#{storage_info['prefix']}/#{application}/#{sub_app}/results/#{type}/#{guid}/data/summary.log"
          result_data['name'] = 'summary.log'

          result = result_data.to_json
      #end
      store.hset("#{application}:#{sub_app}:results:#{type}:#{guid}:data", "results", result)
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
