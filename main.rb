require 'sinatra'
require 'json'
require './Models/models.rb'
require './Models/application.rb'
require './Models/test.rb'
require './Models/request.rb'
require './Models/response.rb'
require './Models/perftest.rb'
require './Models/result.rb'
require './Models/configuration.rb'
  
app_list = {
  :dbaas => Application.new(2, "/applications/dbaas", "Cloud Databases", "cloud databases"),
  :ah => Application.new(1, "/applications/ah", "Atom Hopper", "description"),
  :csl => Application.new(3, "/applications/csl", "Customer Service Layer", "internal application")
} 

results_app_list = {
  :dbaas => Application.new(2, "/results/dbaas", "Cloud Databases", "cloud databases"),
  :ah => Application.new(1, "/results/ah", "Atom Hopper", "description"),
  :csl => Application.new(3, "/results/csl", "Customer Service Layer", "internal application")
} 

load_test_list = {
  :load_test => PerfTest.new(1, '/results/dbaas/load_test','Load Test', 'Test description'),
  :duration_test => PerfTest.new(2, '/results/dbaas/duration_test','Duration Test','Test description'),
  :benchmark_test => PerfTest.new(3, '/results/dbaas/benchmark_test','Benchmark Test','Test description')
}


result_set_list = [
  Result.new(Date.new(2013,1,1), '13.4','17','24','10','32'),
  Result.new(Date.new(2013,1,2), '13.5','23','34','5','15'),
  Result.new(Date.new(2013,1,3), '13.9','34','44','42','20'),
  Result.new(Date.new(2013,1,4), '15.4','12','34','30','23'),
  Result.new(Date.new(2013,1,5), '12.1','34','24','20','23'),
  Result.new(Date.new(2013,1,6), '15.2','23','34','50','17'),
  Result.new(Date.new(2013,1,7), '10.4','53','71','20','9')
]

repose_detail_results_list = [
  Result.new(0, '13.4','17','24','10','32'),
  Result.new(5, '13.5','23','34','5','15'),
  Result.new(10, '13.9','34','44','42','20'),
  Result.new(15, '15.4','12','34','30','23'),
  Result.new(20, '12.1','34','24','20','23'),
  Result.new(25, '15.2','23','34','50','17'),
  Result.new(30, '10.4','53','71','20','9')
]

os_detail_results_list = [
  Result.new(0, '10.4','14.5','20.2','9.3','30.3'),
  Result.new(5, '12.5','20.2','33.3','4','12.2'),
  Result.new(10, '11.9','30.1','40.2','40','10'),
  Result.new(15, '12.4','11.9','31.3','29.2','13'),
  Result.new(20, '11.1','30.9','22.3','19.3','13'),
  Result.new(25, '13.2','20.9','33.6','45.2','7.65'),
  Result.new(30, '9.4','38.2','70.3','15.3','8.2')
]

get '/' do
  erb :index
end

get '/applications' do
  erb :applications, :locals => {:application_list => app_list}
end

get '/applications/:name' do |name|
  app = app_list[name.to_sym]
  app.request_response_list = Test.new(name).test_list
  app.config_list = Configuration.new(name).config_list
  erb :app_detail, :locals => {:app_detail => app}
end

get '/results' do
  erb :results, :locals => {:application_list => results_app_list}
end

get '/results/:name' do |name|
  app = app_list[name.to_sym]
  app.load_test_list = load_test_list
  erb :results_app_detail, :locals => {:app_detail => app}
end

get '/results/:name/:test' do |name, test|
  #get results from db for this test
  app = results_app_list[name.to_sym]
  app.result_set_list = result_set_list
  app.test_type = test
  erb :results_app_test_detail, :locals => {:app_detail => app }
end

get '/results/:name/:test/metric/:metric' do |name, test, metric|
  results = []
  result_set_list.each { |result| results << [result.date.strftime("%Y,%m,%d"), result.send(metric.to_sym).to_f] }
  content_type :json
  body results.to_json
end

get '/results/:name/:test/date/:date' do |name, test, date|
  app = results_app_list[name.to_sym]
  app.repose_detail = repose_detail_results_list
  app.date = date
  app.test_type = test
  app.os_detail = os_detail_results_list
  app.results = app.repose_detail.zip(app.os_detail)
  erb :results_detail, :locals => {:app_detail => app}
end

get '/results/:name/:test/metric/:metric/date/:date' do |name, test, metric, date|
  repose_results = []
  origin_results = []
  repose_detail_results_list.each { |result| repose_results << [result.date, result.send(metric.to_sym).to_f] }
  os_detail_results_list.each { |result| origin_results << [result.date, result.send(metric.to_sym).to_f] }
  results = { :repose => repose_results, :origin => origin_results }
  content_type :json
  body results.to_json
end

