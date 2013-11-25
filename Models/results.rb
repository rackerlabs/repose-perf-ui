require 'json'
require 'yaml'
require_relative 'result.rb'
require_relative 'models.rb'


module Results
  class ComparisonResults
    def test_results(db, fs_ip, test_list)
      #compare 2 guids
      puts "test_list :#{test_list}"
      overhead_test_list = []
      store = Redis.new(db)
      temp_list = []
      begin 
        test_list.each do |test|
          meta_results = store.hgetall("#{test[:application]}:#{test[:name]}:results:#{test[:test_type]}:#{test[:guid]}:meta")
          data_result = store.hget("#{test[:application]}:#{test[:name]}:results:#{test[:test_type]}:#{test[:guid]}:data", "results")
          
          test_json = JSON.parse(meta_results['test'])
          test.merge!(test_json) if test_json
          runner_class = Apps::Bootstrap.runner_list[test_json['runner'].to_sym] if test_json
          summary_data = JSON.parse(data_result)['location']
  
          runner_class.compile_summary_results(test, test[:guid], "http://#{fs_ip}#{summary_data}")

          temp = Result.new(
              test['start'],test[:length],test[:average],
              test[:throughput], test[:errors], test['name'], test['description'], test[:guid], :in_progress)

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

        end
        overhead_test_list = overhead_test_list + temp_list
      ensure
        store.quit
      end  
    end
    
    def detailed_results(db, fs_ip, test_list, id)
      store = Redis.new(db)
      overhead_guid_list = id.split('+')
      results = {}
      begin
        overhead_guid_list.each do |guid|
          test = test_list.find {|t| t[:guid] == guid}
          if test
            meta_results = store.hgetall("#{test[:application]}:#{test[:name]}:results:#{test[:test_type]}:#{test[:guid]}:meta")
            data_result = store.hget("#{test[:application]}:#{test[:name]}:results:#{test[:test_type]}:#{test[:guid]}:data", "results")
          
            test_json = JSON.parse(meta_results['test'])
            test.merge!(test_json) if test_json
            runner_class = Apps::Bootstrap.runner_list[test_json['runner'].to_sym] if test_json
            summary_data = JSON.parse(data_result)['location']

            results[guid] = runner_class.compile_detailed_results(guid, "http://#{fs_ip}#{summary_data}")
          end
        end
        raise ArgumentError, "Both sets of results are not yet available" if results.length == 1
        results
      ensure
        store.quit
      end

=begin
      test_locations = test_list.find_all do |test|
        id == test['guid']
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
=end
    end
    
    def metric_results(results, metric)
      compare_one_results = []
      compare_two_results = []
      if results[0][0].respond_to?(metric.to_sym)
        results[0].each { |result| compare_one_results << [result.start, result.send(metric.to_sym).to_f] }
      end
      if results[1][0].respond_to?(metric.to_sym)
        results[1].each { |result| compare_two_results << [result.start, result.send(metric.to_sym).to_f] }
      end
      { :compare_one => compare_one_results, :compare_two => compare_two_results }
    end

  end
  
  class SingularResults
    
    #get all test results
    def test_results(db, fs_ip, test_list)
      singular_test_list = []
      store = Redis.new(db)
      begin 
        test_list.each do |test|
          meta_results = store.hgetall("#{test[:application]}:#{test[:name]}:results:#{test[:test_type]}:#{test[:guid]}:meta")
          data_result = store.hget("#{test[:application]}:#{test[:name]}:results:#{test[:test_type]}:#{test[:guid]}:data", "results")
          
          test_json = JSON.parse(meta_results['test'])
          test.merge!(test_json) if test_json
          runner_class = Apps::Bootstrap.runner_list[test_json['runner'].to_sym] if test_json
          summary_data = JSON.parse(data_result)['location']
  
          runner_class.compile_summary_results(test, test[:guid], "http://#{fs_ip}#{summary_data}")
          singular_test_list << Result.new(
              test['start'],test[:length],test[:average],
              test[:throughput], test[:errors], test['name'], test['description'], test[:guid])
        end
        singular_test_list
      ensure
        store.quit
      end      
    end
    
    #get all detailed results for one test
    def detailed_results(db, fs_ip, test_list, id)
      store = Redis.new(db)
      test = test_list.find {|t| t[:guid] == id}
      begin
        if test
          meta_results = store.hgetall("#{test[:application]}:#{test[:name]}:results:#{test[:test_type]}:#{test[:guid]}:meta")
          data_result = store.hget("#{test[:application]}:#{test[:name]}:results:#{test[:test_type]}:#{test[:guid]}:data", "results")
          if meta_results and data_result
            test_json = JSON.parse(meta_results['test'])
            runner_class = Apps::Bootstrap.runner_list[test_json['runner'].to_sym] if test_json
            entry = JSON.parse(data_result)['location']
            
            runner_class.compile_detailed_results(id, "http://#{fs_ip}#{entry}")
          end
        end
      ensure
        store.quit
      end
    end
    
    def metric_results(results, metric)
      metric_data = []
      if results[0].respond_to?(metric.to_sym)
        results.each { |result| metric_data << [result.start, result.send(metric.to_sym).to_f] }
      end
      metric_data
    end
  end
  
  class PastSummaryResults
    include ResultModule
    attr_reader :test_list, :store, :logger, :past_summary_results, :summary_view, :detailed_view    

    def initialize(application, name, application_type, test_type, db, fs_ip, config_path = nil, logger = nil)
      @logger = logger if logger
      @logger.debug "application: #{application}" 
      @logger.debug "name: #{name}" 
      @logger.debug "application_type: #{application_type}" 
      @logger.debug "test type: #{test_type}" 
      @logger.debug "db: #{db}" 
      @logger.debug "config path: #{config_path}" 
      initialized_results = Apps::Bootstrap.initialize_results[application_type.to_sym]
      @past_summary_results = initialized_results[:klass]
      @summary_view = initialized_results[:summary_view]
      @detailed_view = initialized_results[:detailed_view]
      
      config = config(config_path)
      @test_list = []
      test_type.chomp!("_test")
      @store = Redis.new(db)
      
      all_test_guids = @store.lrange("#{application}:#{name}:results:#{test_type}", 0, -1)
      
      all_test_guids.each do |guid|
        @test_list << {:guid => guid, :application => application, :name => name, :test_type => test_type}
      end     
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
