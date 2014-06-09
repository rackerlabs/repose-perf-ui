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
      :klass => MockObject
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
     'path' => '/tmp/open-uri20131220-13905-1nbyz35' 
   }
   storage_info = @config['storage_info']
   @runner.store_results(@app,@sub_app,@test, @guid, source_result_info, storage_info, @store)
   assert_equal(
     "{\"location\":\"/files/#{@app}/#{@sub_app}/results/#{@test}/#{@guid}/data/summary.log\",\"name\":\"summary.log\"}", 
     @store.hget("#{@app}:#{@sub_app}:results:#{@test}:#{@guid}:data","results"))
   assert(File.exists?("/tmp/#{@guid}/data/summary.log"))

  end
end 

class MockObject
  def config
    {
      'application' => {
        'sla' => [
         {
          'name' => 'average',
          'limit' => 'upper',
          'value' => 5,
          'value_type' => 'ms',
          'test_type' => ['load']
         },
         {
          'name' => 'throughput',
          'limit' => 'lower',
          'value' => 600,
          'test_type' => ['load','stress']
         },
         {
          'name' => 'errors',
          'limit' => 'upper',
          'value' => 10,
          'test_type' => ['load']
         }
       ],
       'notify' => true,
       'notification' => { 'mail' => 'dimitry.ushakov@rackspace.com'}
     }
   }  
  end
end
