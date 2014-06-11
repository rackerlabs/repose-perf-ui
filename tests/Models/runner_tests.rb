require 'test/unit'
require 'mocha'
require './Models/runner.rb'
require 'yaml'
require 'redis'
require 'securerandom'
require 'fileutils'

class JMeterRunnerTest < Test::Unit::TestCase
  def setup
    @runner = SnapshotComparer::Models::JMeterRunner.new([{
      :id => "test_app",
      :klass => MockSingularObject
    }])
    @config = YAML.load_file(File.expand_path("config/test_config.yaml", Dir.pwd))
    @store = Redis.new({:host => @config['redis']['host'], :port => @config['redis']['port'], :db => @config['redis']['db']})
    @guid = SecureRandom.uuid
    @app = "test_app"
    @sub_app = "test_sub_app"
    @test = "load"
  end

  def teardown
    @store.hdel("#{@app}:#{@sub_app}:results:#{@test}:#{@guid}:data", "results")
    FileUtils.rm_rf("/tmp/#{@guid}")
  end

  def test_store_results
   source_result_info = {
     'server' => 'localhost',
     'user' => 'root',
     'path' => File.expand_path("tests/files/data/summary.log_1", Dir.pwd) 
   }
   storage_info = @config['storage_info']
   @runner.store_results(@app,@sub_app,@test, @guid, source_result_info, storage_info, @store, @config)
   assert_equal(
     "{\"location\":\"/files/#{@app}/#{@sub_app}/results/#{@test}/#{@guid}/data/summary.log\",\"name\":\"summary.log\"}", 
     @store.hget("#{@app}:#{@sub_app}:results:#{@test}:#{@guid}:data","results"))
   assert(File.exists?("/tmp/#{@guid}/data/summary.log"))
  end

  def test_singular_app_store_results_with_successful_sla
    @runner = SnapshotComparer::Models::JMeterRunner.new([{
      :id => "test_app",
      :klass => MockSingularObject
    }])
   source_result_info = {
     'server' => 'localhost',
     'user' => 'root',
     'path' => File.expand_path("tests/files/data/summary.log_1", Dir.pwd) 
   }
   storage_info = @config['storage_info']
   @runner.store_results(@app,@sub_app,@test, @guid, source_result_info, storage_info, @store, @config)
   assert_equal(
     "{\"location\":\"/files/#{@app}/#{@sub_app}/results/#{@test}/#{@guid}/data/summary.log\",\"name\":\"summary.log\"}", 
     @store.hget("#{@app}:#{@sub_app}:results:#{@test}:#{@guid}:data","results"))
   assert(File.exists?("/tmp/#{@guid}/data/summary.log"))
   assert_empty(@runner.notification_validation_results)
  end

  def test_singular_app_store_results_with_failed_sla
    @runner = SnapshotComparer::Models::JMeterRunner.new([{
      :id => "test_app",
      :klass => MockSingularLowSlaObject
    }])
   source_result_info = {
     'server' => 'localhost',
     'user' => 'root',
     'path' => File.expand_path("tests/files/data/summary.log_1", Dir.pwd) 
   }
   storage_info = @config['storage_info']
   @runner.store_results(@app,@sub_app,@test, @guid, source_result_info, storage_info, @store, @config)
   assert_equal(
     "{\"location\":\"/files/#{@app}/#{@sub_app}/results/#{@test}/#{@guid}/data/summary.log\",\"name\":\"summary.log\"}", 
     @store.hget("#{@app}:#{@sub_app}:results:#{@test}:#{@guid}:data","results"))
   assert(File.exists?("/tmp/#{@guid}/data/summary.log"))
   assert_not_empty(@runner.notification_validation_results)
  end
end

class JMeterRunnerWithComparisonAppTest < Test::Unit::TestCase

  def setup
    @config = YAML.load_file(File.expand_path("config/test_config.yaml", Dir.pwd))
    @store = Redis.new({:host => @config['redis']['host'], :port => @config['redis']['port'], :db => @config['redis']['db']})
    @guid = SecureRandom.uuid
    @app = "test_app"
    @sub_app = "test_sub_app"
    @test = "load"
    @comparison_guid = "test_guid_123"
    comparison_guid_data_location = File.expand_path("tests/files/data/summary.log_2", Dir.pwd) 
    @store.hset("#{@app}:#{@sub_app}:results:#{@test}:#{@comparison_guid}:meta", "test", "{\"runner\":\"jmeter\",\"start\":1392340471,\"stop\":1392344078,\"description\":null,\"name\":\"nightly test against master branch\"}")
    @store.hset("#{@app}:#{@sub_app}:results:#{@test}:#{@comparison_guid}:data", "results", "{\"location\":\"#{comparison_guid_data_location}\",\"name\":\"summary.log\"}")
  end

  def teardown
    @store.hdel("#{@app}:#{@sub_app}:results:#{@test}:#{@guid}:data", "results")
    @store.hdel("#{@app}:#{@sub_app}:results:#{@test}:#{@comparison_guid}:meta", "test")
    FileUtils.rm_rf("/tmp/#{@guid}")
  end
  def test_comparison_app_store_results_with_successful_sla
    @runner = SnapshotComparer::Models::JMeterRunner.new([{
      :id => "test_app",
      :klass => MockComparisonObject
    }])
   source_result_info = {
     'server' => 'localhost',
     'user' => 'root',
     'path' => File.expand_path("tests/files/data/summary.log_1", Dir.pwd)
   }
   storage_info = @config['storage_info']
   @runner.store_results(@app,@sub_app,@test, @guid, source_result_info, storage_info, @store, @config, @comparison_guid)
   assert_equal(
     "{\"location\":\"/files/#{@app}/#{@sub_app}/results/#{@test}/#{@guid}/data/summary.log\",\"name\":\"summary.log\"}", 
     @store.hget("#{@app}:#{@sub_app}:results:#{@test}:#{@guid}:data","results"))
   assert(File.exists?("/tmp/#{@guid}/data/summary.log"))
   assert_empty(@runner.notification_validation_results)
  end

  def test_comparison_app_store_results_with_failed_sla
    @runner = SnapshotComparer::Models::JMeterRunner.new([{
      :id => "test_app",
      :klass => MockComparisonLowSlaObject
    }])
   source_result_info = {
     'server' => 'localhost',
     'user' => 'root',
     'path' => File.expand_path("tests/files/data/summary.log_1", Dir.pwd)
   }
   storage_info = @config['storage_info']
   @runner.store_results(@app,@sub_app,@test, @guid, source_result_info, storage_info, @store,@config, @comparison_guid)
   assert_equal(
     "{\"location\":\"/files/#{@app}/#{@sub_app}/results/#{@test}/#{@guid}/data/summary.log\",\"name\":\"summary.log\"}", 
     @store.hget("#{@app}:#{@sub_app}:results:#{@test}:#{@guid}:data","results"))
   assert(File.exists?("/tmp/#{@guid}/data/summary.log"))
   assert_not_empty(@runner.notification_validation_results)
  end
end 

class MockSingularObject
  def config
    {
      'application' => {
        'type' => 'singular',
        'sla' => [
         {'average' => {
          'limit' => 'upper',
          'value' => 10,
          'value_type' => 'ms',
          'test_type' => ['load']
         }},
         {'throughput' => {
          'limit' => 'lower',
          'value' => 400,
          'test_type' => ['load','stress']
         }},
         {'errors' => {
          'limit' => 'upper',
          'value' => 2000,
          'test_type' => ['load']
         }}
       ],
       'notify' => true,
       'notification' => { 'type' => 'mail', 'recipient_list' => 'dimitry.ushakov@rackspace.com'}
     }
   }  
  end
end

class MockSingularLowSlaObject
  def config
    {
      'application' => {
        'type' => 'singular',
        'sla' => [
         {'average' => {
          'limit' => 'upper',
          'value' => 1.9,
          'value_type' => 'ms',
          'test_type' => ['load']
         }},
         {'throughput' => {
          'limit' => 'lower',
          'value' => 500,
          'test_type' => ['load','stress']
         }},
         {'errors' => {
          'limit' => 'upper',
          'value' => 10,
          'test_type' => ['load']
         }}
       ],
       'notify' => true,
       'notification' => { 'type' => 'mail', 'recipient_list' => 'dimitry.ushakov@rackspace.com'}
     }
   }  
  end
end

class MockComparisonObject
  def config
    {
      'application' => {
        'type' => 'comparison',
        'sla' => [
         {'average' => {
          'limit' => 'upper',
          'value' => 10,
          'value_type' => 'ms',
          'test_type' => ['load']
         }},
         {'throughput' => {
          'limit' => 'lower',
          'value' => 0,
          'test_type' => ['load','stress']
         }},
         {'errors' => {
          'limit' => 'upper',
          'value' => 50000,
          'test_type' => ['load']
         }}
       ],
       'notify' => true,
       'notification' => { 'type' => 'mail', 'recipient_list' => 'dimitry.ushakov@rackspace.com'}
     }
   }  
  end
end

class MockComparisonLowSlaObject
  def config
    {
      'application' => {
        'type' => 'comparison',
        'sla' => [
         {'average' => {
          'limit' => 'upper',
          'value' => 1.9,
          'value_type' => 'ms',
          'test_type' => ['load']
         }},
         {'throughput' => {
          'limit' => 'lower',
          'value' => 500,
          'test_type' => ['load','stress']
         }},
         {'errors' => {
          'limit' => 'upper',
          'value' => 10,
          'test_type' => ['load']
         }}
       ],
       'notify' => true,
       'notification' => { 'type' => 'mail', 'recipient_list' => 'dimitry.ushakov@rackspace.com'}
     }
   }  
  end
end
