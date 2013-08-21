require 'json'

class PastResults
  attr_reader :test_list

  def initialize(name, test_type)
    #load all tmp_directories
    @test_list = []
    test_type.chomp!("_test")
    folder_location = "/root/repose/dist/files/apps/#{name}/results/#{test_type}"
    Dir.glob("#{folder_location}/tmp_*").each do |entry| 
      test_hash = {}
      if File.directory?(entry)
        #get directory
        #get begin time, end time, tag name in entry meta file
        test_type = "load" if test_type == "adhoc"
        test_hash.merge!(JSON.parse(File.read("#{entry}/meta/#{test_type}_test.json")))
        #get summary 
        summary_location = "#{entry}/summary.log" 
        summary = `tail -n 3 #{summary_location}`
        summary.scan(/summary =\s+\d+\s+in\s+(\d+(?:\.\d)?)s =\s+(\d+(?:\.\d)?)\/s Avg:\s+(\d+).*Err:\s+(\d+)/).map do |time_offset,throughput,average,errors| 
          test_hash.merge!( {:length => time_offset, :throughput => throughput, :average => average, :errors =>  errors})
        end
        @test_list << test_hash
=begin
  match overhead on id!
  test_list = {
    'ah' => [
       { 
         'id' => 'ah/2.8.3',
         'tag' => 'ah/2.8.3 with repose',
         'start' => start time,
         'end' => end time,
         'runner' => 'jmeter',
         'node_count' => 2,
         'length' => time_offset,
         'throughput' => throughput,
         'average' => average,
         'errors' => errors
       },
       { 
         'id' => 'ah/2.8.3',
         'tag' => 'ah/2.8.3 without repose',
         'start' => start time,
         'end' => end time,
         'runner' => 'jmeter',
         'node_count' => 2,
         'length' => time_offset,
         'throughput' => throughput,
         'average' => average,
         'errors' => errors
       }
     ] 
  }
=end        
      end
    end
  end

=begin
  [ Result.new('start date','test length','average overhead', 'throughput overhead', 'errors overhead', 'id that matches both tests')]
=end
  def overhead_test_results
    overhead_test_list = []
    @test_list.sort_by do |hash|
      hash['start']
    end.group_by do |hash| 
      hash['id']
    end.map do |id, hashes| 
      hashes.reduce do | test_a, test_b|  
        test_a.merge(test_b) do |key, v1, v2| 
          ["length","throughput","average","errors"].include?(key.to_s) ? v1.to_f - v2.to_f : v1 
        end
      end
    end.each do |test|
      overhead_test_list << Result.new(test['start'],test['length'],test[:average],test[:throughput], test[:errors], test['id'], test['tag'])
    end
    overhead_test_list
  end

  def compared_test_results(compare_list)
    p compare_list.inspect
    
    @test_list.find_all do |test|
      compare_list.include? test['id']
    end.sort_by do |hash|
      hash['start']
    end.group_by do |test|
      test['id']
    end
  end
end

class Results
  attr_reader :summary_location, :jmx_location
  attr_accessor :summary_results, :summary_result_times, :jmx_results, :new_summary_results, :time, :test_ended

  def initialize(name, test_type, current_test)
    @summary_results = []
    @jmx_results = []

    @summary_location = "/root/repose/dist/files/apps/#{name}/results/#{test_type}/#{current_test.to_s}/summary.log"
    @jmx_location = "/root/repose/dist/files/apps/#{name}/results/#{current_test.to_s}/#{test_type}/jmx.log"
    @new_summary_results = []
    @summary_result_times = []
    @time = 0
    @test_ended = false
  end


  def convert_summary
    #check if directory exists
    @test_ended = true unless File.exists?(@summary_location)
    return if @test_ended
    File.readlines(@summary_location).each do |line|     
      t = line.scan(/summary \+\s+\d+\s+in\s+(\d+(?:\.\d)?)s =\s+(\d+(?:\.\d)?)\/s Avg:\s+(\d+).*Err:\s+(\d+)/)
      @time = @time + t[0][0].to_i unless t.empty?
      @summary_result_times << @time
      @summary_results << SummaryResult.new(@time, t[0][1], t[0][2], t[0][3]) unless t.empty?
      @test_ended = true if line.include? "... end of run"
    end 
    p @summary_results.inspect
  end

  def convert_jmx
    #loop through file.  get CPU, Heap Memory, Network, Disk i/o
  end

  def on_summary_change
    #this is a threaded method that always checks for a new data and write to @new_summary_results.  When test finishes, close the thread
    t = Thread.new {
      #listen to file here.  set to @summary endif fitest completes
      until @test_ended
        temp_time = 0
        @new_summary_results = []
        File.readlines(@summary_location).each do |line|     
          t = line.scan(/summary \+\s+\d+\s+in\s+(\d+(?:\.\d)?)s =\s+(\d+(?:\.\d)?)\/s Avg:\s+(\d+).*Err:\s+(\d+)/)
          temp_time = temp_time + t[0][0].to_i unless t.empty?
          unless @summary_result_times.include? temp_time
            @new_summary_results << SummaryResult.new(temp_time, t[0][1], t[0][2], t[0][3]) unless t.empty?
          end
          @test_ended = true if line.include? "... end of run"
        end 
        sleep 5
      end
      Thread.kill
    }
  end

  def new_summary_values
    #populate from @new_summary_results.  Clear new_summary_results
    @new_summary_results = []
    temp_time = 0
    File.readlines(@summary_location).each do |line|     
      t = line.scan(/summary \+\s+\d+\s+in\s+(\d+(?:\.\d)?)s =\s+(\d+(?:\.\d)?)\/s Avg:\s+(\d+).*Err:\s+(\d+)/)
      temp_time = temp_time + t[0][0].to_i unless t.empty?
      unless @summary_result_times.include? temp_time
         @summary_result_times << temp_time
         @new_summary_results << SummaryResult.new(temp_time, t[0][1], t[0][2], t[0][3]) unless t.empty?
      end
      @test_ended = true if line.include? "... end of run"
    end 
    p @summary_results.inspect
    p @summary_results.size
    p @new_summary_results.inspect
    @summary_results = @new_summary_results + @summary_results
    @new_summary_results
  end

  def new_jmx_values(metric)
    #populate from @new_summary_results.  Clear new_summary_results

  end

end
