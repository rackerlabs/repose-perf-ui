require 'json'
require 'yaml'
require_relative 'result.rb'
require_relative 'models.rb'
require_relative 'application_test_type.rb'

module SnapshotComparer
  module Models
  class ComparisonResults
    def test_results(db, fs_ip, test_list)
      #compare 2 guids
      overhead_test_list = []
      store = Redis.new(db)
      temp_list = []
      begin
        test_list.each do |test|
          meta_results = store.hgetall("#{test[:application]}:#{test[:name]}:results:#{test[:test_type]}:#{test[:guid]}:meta")
          data_result = store.hget("#{test[:application]}:#{test[:name]}:results:#{test[:test_type]}:#{test[:guid]}:data", "results")
          if meta_results && data_result && !data_result.empty? && !meta_results.empty?
            test_json = JSON.parse(meta_results['test'])
            test.merge!(test_json) if test_json
            runner_class = Apps::Bootstrap.runner_list[test_json['runner'].to_sym] if test_json
            summary_data = JSON.parse(data_result)['location']

            runner_class.compile_summary_results(test, test[:guid], "http://#{fs_ip}#{summary_data}") if summary_data

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
                "#{result_to_compare.id}+#{temp.id}",
                :completed,
                ApplicationTestType.new(store,nil).get_status_for_guid(test[:application], test[:name], test[:test_type], "#{result_to_compare.id}+#{temp.id}")) if result_to_compare
              temp_list.delete(result_to_compare)
            else
              temp_list << temp
            end
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
    end

    def metric_results(results, metric)
      metric_results_hash = {}
      results.each do |guid, guid_result|
        if guid_result[0].respond_to?(metric.to_sym)
          metric_results_hash[guid] = []
          guid_result.each { |result| metric_results_hash[guid] << [result.start, result.send(metric.to_sym).to_f] }
        end
      end
      metric_results_hash
    end

  end

  class SingularResults
    include Models

    #get all test results
    def test_results(db, fs_ip, test_list)
      singular_test_list = []
      store = Redis.new(db)
      begin
        test_list.each do |test|
          meta_results = store.hgetall("#{test[:application]}:#{test[:name]}:results:#{test[:test_type]}:#{test[:guid]}:meta")
          data_result = store.hget("#{test[:application]}:#{test[:name]}:results:#{test[:test_type]}:#{test[:guid]}:data", "results")
          if meta_results && data_result && !data_result.empty? && !meta_results.empty?
            test_json = JSON.parse(meta_results['test'])
            test.merge!(test_json) if test_json
            runner_class = Apps::Bootstrap.runner_list[test_json['runner'].to_sym] if test_json
            summary_data = JSON.parse(data_result)['location']
            runner_class.compile_summary_results(test, test[:guid], "http://#{fs_ip}#{summary_data}")
            singular_test_list << Result.new(
                test['start'],test[:length],test[:average],
                test[:throughput], test[:errors], test['name'], test['description'], test[:guid])
          end
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
      end if results
      metric_data
    end
  end

  class PastSummaryResults
    include Models
    attr_reader :test_list, :store, :logger, :past_summary_results, :summary_view, :detailed_view

    def initialize(application, name, application_type, test_type, db, fs_ip, config_path = nil, logger = nil)
      @logger = logger if logger
      @logger.debug "application: #{application}"
      @logger.debug "name: #{name}"
      @logger.debug "application_type: #{application_type}"
      @logger.debug "test type: #{test_type}"
      @logger.debug "db: #{db}"
      @logger.debug "config path: #{config_path}"
      initialized_results = SnapshotComparer::Apps::Bootstrap.initialize_results[application_type.to_sym]
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
  end

  class LiveSummaryResults
    include Models

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
        results = LiveSummaryResults.new(name, test)
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
  
  class Results
      def get_running_test(db, app, sub_app, type)
        store = Redis.new(db)
        result = nil
        begin
          result = store.get("#{app}:test:#{sub_app}:#{type}:start")
        ensure
          store.quit
        end
        result
      end

      def get_state(db, app, sub_app, type)
        store = Redis.new(db)
        result = nil
        begin
          result = store.get("#{app}:test:#{sub_app}:#{type}:temp_start")
        ensure
          store.quit
        end
        result
      end
  end
end
end
