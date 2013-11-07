require 'json'
require 'yaml'
require_relative 'result.rb'
require_relative 'models.rb'


module Results
  class PastNetworkResults
    include ResultModule
    attr_reader :test_list

    def self.format_network(network_results,metric,temp_network_results, header_descriptions={})
      temp_network_results[metric] = {}
      temp_network_results[metric][:content] = {}
      temp_network_results[metric][:headers] = network_results.keys 
      temp_network_results[metric][:description] = header_descriptions
      network_results.each do |k,v|
        v.each do |y|
          temp_network_results[metric][:content][y[:dev_name]] = []
          temp_network_results[metric][:description][y[:dev_name]] = y[:description]
        end
      end
      network_results.each do |k,v|
        v.each do |y|
          temp_network_results[metric][:content][y[:dev_name]] << y[:results]
        end
      end
      temp_network_results
    end
  end 

  class PastSummaryResults
    include ResultModule
    attr_reader :test_list, :store

    def initialize(application, name, application_type, test_type, db, config_path = nil)
      config = config(config_path)
      @test_list = []
      test_type.chomp!("_test")
      
=begin      
      results meta are stored in application:sub_app:results:test_type:meta list
        - {'id':id_timestamp, '[test-type]_test_[runner].json':'base64', 'auth_responder.js':'base64', 'jmxparams.json':'base64'}
      #results configs are stored in application:sub_app:results:test_type:configs hash
        - {'id':id_timestamp, 'config.xml':'base64'}
      #results results are stored in application:sub_app:results:test_type:results hash
        - {'id':id_timestamp, 'summary.log': 'base64'}
=end
      @store = Redis.new(db)
      
      meta_results = @store.hgetall("#{application}:#{name}:results:#{test_type}:meta")
      config_results = @store.hgetall("#{application}:#{name}:results:#{test_type}:configs")
      result_results = @store.hgetall("#{application}:#{name}:results:#{test_type}:results")
      
      meta_results.each do |meta|
        Apps::Bootstrap.runner_list
      end
      
      
      folder_location = "#{config['home_dir']}/files/apps/#{name}/results/#{test_type}"

      Dir.glob("#{folder_location}/tmp_*").each do |entry| 
        test_hash = {}
        if File.directory?(entry)
          #get directory
          #get begin time, end time, tag name in entry meta file
          #test_type = "load" if test_type == "adhoc"
          test_json = JSON.parse(File.read("#{entry}/meta/#{test_type}_test.json")) if File.exists?("#{entry}/meta/#{test_type}_test.json")
          test_hash.merge!(test_json) if test_json

          #get runner and parse data from runner
          runner_class = Models::Bootstrap.new.runner_list[test_json['runner'].to_sym] if test_json

          #get summary 
          @test_list << runner_class.compile_summary_results(test_hash, entry) if runner_class
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
      result = (test_locations[0] != nil) ? test_locations[0] : test_locations[1]
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
        time_line = line.scan(/summary \=\s+\d+\s+in\s+(\d+(?:\.\d)?)s/) 
        t = line.scan(/summary \+\s+\d+\s+in\s+(\d+(?:\.\d)?)s =\s+(\d+(?:\.\d)?)\/s Avg:\s+(\d+).*Err:\s+(\d+)/)
        temp_time = time_line[0][0].to_i unless time_line.empty?
        repose_summary_results << SummaryResult.new(temp_time, t[0][1], t[0][2], t[0][3]) unless t.empty?
      end if File.exists?("#{repose_results}/summary.log")

      temp_time = 0
      os_summary_results = []
      File.readlines("#{os_results}/summary.log").each do |line|     
        time_line = line.scan(/summary \=\s+\d+\s+in\s+(\d+(?:\.\d)?)s/) 
        t = line.scan(/summary \+\s+\d+\s+in\s+(\d+(?:\.\d)?)s =\s+(\d+(?:\.\d)?)\/s Avg:\s+(\d+).*Err:\s+(\d+)/)
        temp_time = time_line[0][0].to_i unless time_line.empty?
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
