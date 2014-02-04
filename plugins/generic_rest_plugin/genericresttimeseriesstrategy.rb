require_relative 'abstractstrategy.rb'

module GenericRestPluginModule
  class GenericRestTimeSeriesStrategy < GenericRestPluginModule::AbstractStrategy
  
    attr_accessor :average_metric_list,:detailed_metric_list 
    
    def self.metric_description
      {
      }
    end
  
    def initialize(db, fs_ip, application, name, test_type, id, metric_id)
      @average_metric_list = {}
  
      @detailed_metric_list = {}
      super(db, fs_ip, application, name, test_type, id, metric_id)
    end 
  
    def populate_metric(entry, name, id, template, start, stop)
      output = open(entry).read
      results = JSON.parse(output) if output
      puts "results: #{results}"
      parsed_template = match_vs_template(template, results)

      if results
        #1. set average_metric_list and detailed_metric_list
        #2. set metric_description (probably to nil or maybe load from config????)
        #ITERATE FROM TEMPLATE
        parsed_template.each do |template_key, template_steps|
          if template_key == "<METRIC_NAME>"
            #get every metric set up and then for that metric, populate the datapoints
            template_steps.each do |template_step|
              
            end
          elsif template_key == "<DATAPOINT_VALUE>" || template_key == "<DATAPOINT_TIMESTAMP>"
            
          end
        end
        results.each do |target|
          datapoint_results = []
          average_results = 0
          target['datapoints'].each do |datapoint|
            datapoint_results << {:time => datapoint[1], :value => datapoint[0]}
            average_results = average_results + datapoint[0]
          end
          #get METRIC_NAME
          @detailed_metric_list[target['target']] = [
            {:dev_name => name, :results => datapoint_results}
          ]
          @average_metric_list[target['target']] = [
            {:dev_name => name, :results => (average_results/target['datapoints'].length)}
          ]
        end
      end
    end
        
    def check_list(hash)
      result = hash.find do |key, value|
        value == false
      end
      result
    end
    
    def check_vs_template(current_template, response, template_name, results_path, is_found)
      unless results_path[:is_found]
        if current_template.is_a?(Hash)
          current_template.each do |key, value|
            if template_name == value
              results_path[:results] << "hash.key=#{key}.stringvalue"
              results_path[:is_found] = true
              results_path
              break
            else
              results_path[:results] << "hash.key=#{key}"
              results_path = check_vs_template(value, response, template_name, results_path, results_path[:is_found])
            end
          end
        elsif current_template.is_a?(Array)
          current_template.each_with_index do |id, index|
            if template_name == id
              results_path[:results] << "list[#{index}]"
              results_path[:is_found] = true
              results_path
              break
            else
              results_path[:results] << "list"
              results_path = check_vs_template(id, response, template_name, results_path, results_path[:is_found])
            end
          end
        end
        results_path[:results].pop unless results_path[:is_found]
      end
      results_path
    end
    
    def match_vs_template(current_template, response)
      template_name_list = {
        '<METRIC_NAME>' => nil, 
        '<DATAPOINT_VALUE>' => nil, 
        '<DATAPOINT_TIMESTAMP>' => nil
      }
      template_name_list.each do |key, value|
        results_path = {:results => [], :is_found => false}
        template_name_list[key] = check_vs_template(current_template, response, key, results_path, false)[:results]        
      end
      puts template_name_list
      template_name_list
    end
    
    
    
  end
end