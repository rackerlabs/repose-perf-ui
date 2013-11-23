
class IO
  TAIL_BUF_LENGTH = 1 << 16

  def tail(n)
    return [] if n < 1
 
    seek -TAIL_BUF_LENGTH, SEEK_END
  
    buf = ""
    while buf.count("\n") <= n
      p n
      p buf
      buf = read(TAIL_BUF_LENGTH) + buf
      seek 2 * -TAIL_BUF_LENGTH, SEEK_CUR
    end
  
    buf.split("\n")[-n..-1]
  end
end

module Models
  class JMeterRunner
    def compile_summary_results(test_hash, guid, entry)
        p entry
      temp_hash = {}
      summary_list = open(entry) do |f|
        IO.readlines(f)[-5..-1]
      end
      summary_list.each do |summary|
        summary.scan(/summary =\s+\d+\s+in\s+(\d+(?:\.\d)?)s =\s+(\d+(?:\.\d)?)\/s Avg:\s+(\d+).*Err:\s+(\d+)/).map do |time_offset,throughput,average,errors| 
          temp_hash[:length] = time_offset
          temp_hash[:throughput] = throughput
          temp_hash[:average] = average
          temp_hash[:errors] = errors
        end
      end 
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
  end

	class PravegaRunner
	end

	class FloodRunner
	end

	class AutoBenchRunner
	end

end
