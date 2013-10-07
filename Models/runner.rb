module Models
	class JMeterRunner
	  def compile_summary_results(test_hash, entry)
        summary_location = "#{entry}/summary.log" 
        summary = `grep -B 1 Tidying #{summary_location}`
        summary.scan(/summary =\s+\d+\s+in\s+(\d+(?:\.\d)?)s =\s+(\d+(?:\.\d)?)\/s Avg:\s+(\d+).*Err:\s+(\d+)/).map do |time_offset,throughput,average,errors| 
          test_hash.merge!( 
          	{
          		:length => time_offset, 
          		:throughput => throughput, 
          		:average => average, 
          		:errors =>  errors, 
          		:folder_name => entry
          	}
          )
        end
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
