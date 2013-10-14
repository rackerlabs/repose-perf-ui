module Models
  class JMeterRunner
    def compile_summary_results(test_hash, entry)
      temp_hash = {:folder_name => entry }
      summary_location = "#{entry}/summary.log" 
      summary = `grep -B 1 Tidying #{summary_location}`
      summary.scan(/summary =\s+\d+\s+in\s+(\d+(?:\.\d)?)s =\s+(\d+(?:\.\d)?)\/s Avg:\s+(\d+).*Err:\s+(\d+)/).map do |time_offset,throughput,average,errors| 
        temp_hash[:length] = time_offset
        temp_hash[:throughput] = throughput
        temp_hash[:average] = average
        temp_hash[:errors] = errors
      end 
      test_hash.merge!(temp_hash) 
      test_hash
    end
  end

	class PravegaRunner
	end

	class FloodRunner
	end

	class AutoBenchRunner
	end

end
