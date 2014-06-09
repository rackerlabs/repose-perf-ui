require 'test/unit'
require './Models/runner.rb'
require 'yaml'
require 'redis'
require 'securerandom'
require 'fileutils'

class JMeterRunnerTest < Test::Unit::TestCase
  def setup
    @runner = SnapshotComparer::Models::JMeterRunner.new
    @config = YAML.load_file(File.expand_path("config/test_config.yaml", Dir.pwd))
    @store = Redis.new({:host => @config['redis']['host'], :port => @config['redis']['port'], :db => @config['redis']['db']})
    @guid = SecureRandom.uuid
  end

  def teardown
    @store.hdel("test_app:test_sub_app:results:load:#{@guid}:data", "results")
    FileUtils.rm_rf("/tmp/#{@guid}")
  end

  def test_store_results
   source_result_info = {
     'server' => 'localhost',
     'user' => 'root',
     'path' => '/tmp/open-uri20131220-13905-1nbyz35' 
   }
   storage_info = @config['storage_info']
   @runner.store_results('test_app','test_sub_app','load', @guid, source_result_info, storage_info, @store)
   assert_equal(
     "{\"location\":\"/files/test_app/test_sub_app/results/load/#{@guid}/data/summary.log\",\"name\":\"summary.log\"}", 
     @store.hget("test_app:test_sub_app:results:load:#{@guid}:data","results"))
   assert(File.exists?("/tmp/#{@guid}/data/summary.log"))

  end
end 
