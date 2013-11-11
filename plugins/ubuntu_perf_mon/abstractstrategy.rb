require_relative './../../Models/models.rb'

class AbstractStrategy
  include ResultModule

  attr_reader :folder_location

  def self.metric_description
    {}
  end

=begin
  TODO: move folder location to redis.  Rest remains the same
  input: 
    app - bootstrap class (Repose, AH, etc)
    application - app name (repose, atom_hopper, etc)
    name - sub app name (main, all_filters, etc)
    test_type - test type (load, adhoc, etc)
    id - guid
  action:
    get data result from sysstats
    get meta results
    populate @average_metric_list and @detailed_metric_list lists 
=end
  def initialize(app, application, name, test_type, id, test_json, config_path)
    store = Redis.new(app.db)
    application_type = app.config['application']['type'].to_sym
    test_type.chomp!("_test")
    data_result = store.hget("#{application}:#{name}:results:#{test_type}:#{id}:data", "sysstats")
    #{'locations':['path1','path2']}
    entries = JSON.parse(data_result)['locations']
    
    populate_metric(entries, fs_ip, id, test_json['start'], test_json['stop'])
  end

  def initialize_metric(list,key, dev, description = "")
    unless list[key].find{|key_data| key_data.has_key?(:dev_name) and key_data[:dev_name] == dev}
      list[key] << {:dev_name  => dev, :results => [], :description => description}
    end
  end 
end



