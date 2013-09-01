require 'json'
require 'yaml'
require_relative 'result.rb'
require_relative 'models.rb'



module Results

  class PastJmxResults  
    include ResultModule
    attr_reader :test_list

    def jmx_categories
     {
        :gc =>  [
          'GarbageCollectorImpl.PSScavenge.CollectionTime',
          'GarbageCollectorImpl.PSScavenge.CollectionCount',
          'GarbageCollectorImpl.PSMarkSweep.CollectionTime',
          'GarbageCollectorImpl.PSMarkSweep.CollectionCount'],
        :memoryimpl => [
          'MemoryPoolImpl.CodeCache.Usage_committed',
          'MemoryPoolImpl.CodeCache.Usage_init',
          'MemoryPoolImpl.CodeCache.Usage_max',
          'MemoryPoolImpl.CodeCache.Usage_used'],
        :memory => [
          'MemoryImpl.HeapMemoryUsage_committed',
          'MemoryImpl.HeapMemoryUsage_init',
          'MemoryImpl.HeapMemoryUsage_max',
          'MemoryImpl.HeapMemoryUsage_used',
          'MemoryImpl.NonHeapMemoryUsage_committed',
          'MemoryImpl.NonHeapMemoryUsage_init',
          'MemoryImpl.NonHeapMemoryUsage_max',
          'MemoryImpl.NonHeapMemoryUsage_used'],
        :os => [
          'UnixOperatingSystem.OpenFileDescriptorCount',
          'UnixOperatingSystem.MaxFileDescriptorCount',
          'UnixOperatingSystem.CommittedVirtualMemorySize',
          'UnixOperatingSystem.TotalSwapSpaceSize',
          'UnixOperatingSystem.FreeSwapSpaceSize',
          'UnixOperatingSystem.ProcessCpuTime',
          'UnixOperatingSystem.FreePhysicalMemorySize',
          'UnixOperatingSystem.TotalPhysicalMemorySize',
          'UnixOperatingSystem.SystemLoadAverage'],
        :threading => [
          'ThreadImpl.PeakThreadCount',
          'ThreadImpl.DaemonThreadCount',
          'ThreadImpl.ThreadCount',
          'ThreadImpl.TotalStartedThreadCount'] 
      }
    end

    def initialize(name, test_type, config_path = nil)
      config = config(config_path)
      #load all tmp_directories
      @test_list = []
      test_type.chomp!("_test")
      folder_location = "#{config['home_dir']}/files/apps/#{name}/results/#{test_type}"
      

      Dir.glob("#{folder_location}/tmp_*").each do |entry| 
        if File.directory?(entry)
          #get directory
          #get begin time, end time, tag name in entry meta file
          test_type = "load" if test_type == "adhoc"
          #get jxm data like so
          @test_list << parse_file(entry)
        end
      end
    end

=begin
 {
  :os => {
    'UnixOperatingSystem.OpenFileDescriptorCount' => [
       {
         :timestamp => 1234,
         :value => 5
       },
       {
         :timestamp => 1236,
         :value => 6
       },
     ],
    'UnixOperatingSystem.MaxFileDescriptorCount' => [ ... ]
    },
  :memory => { ... },
  ...
 }
   
=end
    def parse_file(entry)
      jmx_list = []
      Dir.glob("#{entry}/jmxdata*").each do |jmx_file|
        #jmx files per test
        test_hash = {:name => File.basename(jmx_file)}
        File.open(jmx_file).each do |line|
          #localhost_9999.sun_management_MemoryImpl.HeapMemoryUsage_committed      79364096        1377570793582
          line.scan(/(\S+)\s+(\d+)\s+(\d+)/).map do |jmx_name, value, timestamp|
            #find value in jmx categories
            jmx_category = jmx_categories.map do |key, jmx_entry_list| 
              result = jmx_entry_list.find {|j| 
                jmx_name.include?(j)
              } 
              {key => result} if result  
            end.compact.first
            category_key = jmx_category.keys.first
            jmx_value = jmx_category.values.first
            #check if temp_hash has this key
            #check if temp_hash[category_key] has this value
            #add the following to a list below these values
            test_hash.merge!({category_key => {}}) unless test_hash.key?(category_key)
            test_hash[category_key].merge!({jmx_value => []}) unless test_hash[category_key].key?(jmx_value)
            test_hash[category_key][jmx_value] << {:timestamp => timestamp, :value => value}
          end           
        end
        jmx_list << test_hash
      end
      jmx_list
    end
  end

  class PastSummaryResults
    include ResultModule
    attr_reader :test_list

    def initialize(name, test_type, config_path = nil)
      config = config(config_path)
      #load all tmp_directories
      @test_list = []
      test_type.chomp!("_test")
      folder_location = "#{config['home_dir']}/files/apps/#{name}/results/#{test_type}"
      

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
            test_hash.merge!( {:length => time_offset, :throughput => throughput, :average => average, :errors =>  errors, :folder_name => entry})
          end
          @test_list << test_hash
        end
      end

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

    def detailed_results_file_location(id)
      test_locations = @test_list.find_all do |test|
        id == test['id']
      end.sort_by do |hash|
        hash['start']
      end.map do |test|
        test[:folder_name]
      end

      raise 'Id not found' if test_locations.empty?
      test_locations[0]
    end

    def detailed_results(id)
      test_locations = @test_list.find_all do |test|
        id == test['id']
      end.sort_by do |hash|
        hash['start']
      end.map do |test|
        test[:folder_name]
      end

      raise "Both repose and origin results are not yet available" unless test_locations.length == 2

      repose_results = test_locations[0]
      os_results = test_locations[1]
      temp_time = 0
      repose_summary_results = []
      File.readlines("#{repose_results}/summary.log").each do |line|     
        t = line.scan(/summary \+\s+\d+\s+in\s+(\d+(?:\.\d)?)s =\s+(\d+(?:\.\d)?)\/s Avg:\s+(\d+).*Err:\s+(\d+)/)
        temp_time = temp_time + t[0][0].to_i unless t.empty?
        repose_summary_results << SummaryResult.new(temp_time, t[0][1], t[0][2], t[0][3]) unless t.empty?
      end if File.exists?("#{repose_results}/summary.log")
      
      temp_time = 0
      os_summary_results = []
      File.readlines("#{os_results}/summary.log").each do |line|     
        t = line.scan(/summary \+\s+\d+\s+in\s+(\d+(?:\.\d)?)s =\s+(\d+(?:\.\d)?)\/s Avg:\s+(\d+).*Err:\s+(\d+)/)
        temp_time = temp_time + t[0][0].to_i unless t.empty?
        os_summary_results << SummaryResult.new(temp_time, t[0][1], t[0][2], t[0][3]) unless t.empty?
      end  if File.exists?("#{os_results}/summary.log")
      [repose_summary_results,os_summary_results]
    end

=begin
  [ Result.new('start date','test length','average overhead', 'throughput overhead', 'errors overhead', 'id that matches both tests')]
=end
    def overhead_test_results
      overhead_test_list = []
      group_results(@test_list).map do |id, hashes| 
        hashes.reduce do | test_a, test_b|  
          test_a.merge(test_b) do |key, v1, v2| 
            ["length","throughput","average","errors"].include?(key.to_s) ? (v1.to_f - v2.to_f) : v1 
          end
        end
      end.each do |test|
        overhead_test_list << Result.new(test['start'],test['length'],test[:average],test[:throughput], test[:errors], test['id'], test['tag'])
      end
      overhead_test_list
    end

    def compared_test_results(compare_list)
      list = @test_list.find_all do |test|
        compare_list.include? test['id']
      end if compare_list
      grouped_results = group_results(list)
      grouped_results ? grouped_results : {}
    end

    def group_results(list)
      list.sort_by do |hash|
        hash['start']
      end.group_by do |hash| 
        hash['id']
      end if list
    end
  end

  class LiveSummaryResults
    include ResultModule

    attr_reader :summary_location
    attr_accessor :summary_results, :summary_result_times, :new_summary_results, :time, :test_ended

    @@running_tests = {}

    def self.running_tests
      return @@running_tests
    end

    def initialize(name, test_type, config_path = nil)
      config = config(config_path)
      @summary_results = []
      @summary_location = "#{config['home_dir']}/files/apps/#{name}/results/#{test_type}/current/summary.log"
      @new_summary_results = []
      @summary_result_times = []
      @time = 0
      @test_ended = false
    end

    def self.start_running_results(name, test)
      if !@@running_tests.has_key?(name) or !@@running_tests[name].include?(test) then
        results = Results::LiveSummaryResults.new(name, test)
        results.convert_summary
        @@running_tests[name] = {} unless @@running_tests.has_key?(name)
        @@running_tests[name].merge!({test => results})
      end
      @@running_tests[name][test]
    end



    def convert_summary(interval = 5)
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
      on_summary_change(interval)
    end

    def on_summary_change(interval)
      Thread.abort_on_exception = true
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
          sleep interval
        end
      } if File.exists?(@summary_location)

    end

    def new_summary_values
      @summary_results = @new_summary_results + @summary_results
      @new_summary_results
    end
  end
end