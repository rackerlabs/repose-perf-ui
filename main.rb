require 'sinatra'
require 'json'
require './Models/models.rb'
require './Models/application.rb'
require './Models/test.rb'
require './Models/request.rb'
require './Models/response.rb'
require './Models/perftest.rb'
require './Models/result.rb'
require './Models/results.rb'
require './Models/configuration.rb'
require './Models/testlocation.rb'
require './Models/database.rb'

db = Database.new
db.upgrade 1
db.load_apps (
  {
    :dbaas => Application.new(0,"Cloud Databases", "cloud databases"),
    :ah => Application.new(0,"Atom Hopper", "description"),
    :csl => Application.new(0,"Customer Service Layer", "internal application"),
    :passthrough => Application.new(0,"Passthrough (no filters)", "internal application"),
    :ddrl => Application.new(0,"Dist Datastore + Rate Limiting", "internal application")
  } 
)  

app_list = db.retrieve_apps
 
load_test_list = {
  :load_test => PerfTest.new(1, 'Load Test', 'Test description'),
  :duration_test => PerfTest.new(2, 'Duration Test','Test description'),
  :benchmark_test => PerfTest.new(3, 'Benchmark Test','Test description'),
  :adhoc_test => PerfTest.new(4, 'Adhoc Test','Test description')
}

=begin
result_set_list = [
  Result.new(Date.new(2013,1,1), '13.4','17','24','10','32'),
  Result.new(Date.new(2013,1,2), '13.5','23','34','5','15'),
  Result.new(Date.new(2013,1,3), '13.9','34','44','42','20'),
  Result.new(Date.new(2013,1,4), '15.4','12','34','30','23'),
  Result.new(Date.new(2013,1,5), '12.1','34','24','20','23'),
  Result.new(Date.new(2013,1,6), '15.2','23','34','50','17'),
  Result.new(Date.new(2013,1,7), '10.4','53','71','20','9')
]
=end

results = nil

get '/' do
  erb :index
end

get '/applications' do
  erb :applications, :locals => {:application_list => app_list}
end

get '/applications/:name' do |name|
  app = app_list[name.to_sym]
  app.app_id = name.to_sym
  app.request_response_list = Test.new(name).test_list
  app.config_list = Configuration.new(name).config_list
  app.test_location = TestLocation.new(name)
  erb :app_detail, :locals => {:app_detail => app}
end

get '/applications/:name/test_download/:file_name' do |name, file_name|
  send_file TestLocation.new(name).download, :filename => file_name, :type => 'Application/octet-stream'
end

get '/tests' do
  erb :tests, :locals => {:application_list => app_list}
end

get '/tests/:name' do |name|
  #get scheduled tests, running tests, and ability to start test (either with default values or upload own config and/or test)
  app = app_list[name.to_sym]
  app.load_test_list = load_test_list
  app.app_id = name.to_sym
  erb :tests_app_detail, :locals => {:app_detail => app}
end

get '/tests/:name/:test' do |name, test|
  app = app_list[name.to_sym]
  app.results = Results.new(name, 'adhoc', :current)
  app.results.convert_summary
  app.result_set_list = app.results.summary_results 
  app.test_type = test
  erb :tests_app_test_detail, :locals => {:app_detail => app }
end

get '/tests/:name/:test/metric/:metric' do |name, test, metric|
  #parse from summary file and jmx filei
  app = app_list[name.to_sym]
  temp_results = []
  app.result_set_list.each { |result| p result.inspect; temp_results << [result.date, result.send(metric.to_sym).to_f] }
  content_type :json
  response = { :results => temp_results, :ended => app.results.test_ended}
  body response.to_json
end

get '/tests/:name/:test/metric/:metric/live' do |name, test, metric|
  #get last values from summary file and jmx file
  app = app_list[name.to_sym]
  temp_results = []
  app.results.new_summary_values.each { |result| temp_results << [result.date, result.send(metric.to_sym).to_f] } unless app.results.test_ended
  content_type :json
  response = { :results => temp_results, :ended => app.results.test_ended}
  body response.to_json
end

get '/results' do
  erb :results, :locals => {:application_list => app_list}
end

get '/results/:name' do |name|
  app = app_list[name.to_sym]
  app.app_id = name.to_sym
  app.load_test_list = load_test_list
  erb :results_app_detail, :locals => {:app_detail => app}
end

get '/results/:name/:test' do |name, test|
  #get result files from file under  files/apps/:name/results/:test/summary
  app = app_list[name.to_sym]
  app.results = PastResults.new(name, test)
  app.result_set_list = app.results.overhead_test_results
  p app.inspect
  app.test_type = test
  erb :results_app_test_detail, :locals => {:app_detail => app }
end

post '/results/:name/:test' do |name, test|
  app = app_list[name.to_sym]
  app.compared_result_set_list = app.results.compared_test_results(params[:compare])
  p app.compared_result_set_list.inspect
  erb :results_app_test_compare, :locals => {:app_detail => app }
end

get '/results/:name/:test/metric/:metric' do |name, test, metric|
  #parse from previous result_set
  app = app_list[name.to_sym]
  results = []
  app.result_set_list.each { |result| results << [result.date, result.send(metric.to_sym).to_f] }
  content_type :json
  body results.to_json
end

get '/results/:name/:test/date/:date' do |name, test, date|
  #get result files from file under files/apps/:name/results/:test/:date
  app = app_list[name.to_sym]
  #group by then order by start time.  The first will always be repose
  app.repose_detail = repose_detail_results_list
  app.date = date
  app.test_type = test
  app.os_detail = os_detail_results_list
  app.results = app.repose_detail.zip(app.os_detail)
  erb :results_detail, :locals => {:app_detail => app}
end

get '/results/:name/:test/metric/:metric/date/:date' do |name, test, metric, date|
  #get result files from file under files/apps/:name/results/:test/:date/:metric
  repose_results = []
  origin_results = []
  repose_detail_results_list.each { |result| repose_results << [result.date, result.send(metric.to_sym).to_f] }
  os_detail_results_list.each { |result| origin_results << [result.date, result.send(metric.to_sym).to_f] }
  results = { :repose => repose_results, :origin => origin_results }
  content_type :json
  body results.to_json
end

