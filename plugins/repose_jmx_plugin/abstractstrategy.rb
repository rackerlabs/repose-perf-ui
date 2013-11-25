class ReposeAbstractStrategy

  attr_reader :data_results, :store

  def initialize(db, fs_ip, application, name, test_type, id)
    @store = Redis.new(db) 
    results = {}
    begin 
      test_type.chomp!("_test")
      @data_results = @store.hgetall("#{application}:#{name}:results:#{test_type}:#{id}:data")
      meta_result = @store.hget("#{application}:#{name}:results:#{test_type}:#{id}:meta", "test")
      @data_results.each do |key, data_result|
        if key.start_with?("repose_jmx_plugin")
          #load the file
          json_file = JSON.parse(meta_result)
          entry = JSON.parse(data_result)['location']
          name = JSON.parse(data_result)['name']
          results[json_file['name']] = populate_metric("http://#{fs_ip}/#{entry}", name, id, json_file['start'], json_file['stop']) if json_file
        end
      end
    ensure
      @store.quit
    end
    results
  end

  def initialize_metric(list,key, dev)
    unless list[key].find{|key_data| key_data.has_key?(:dev_name) and key_data[:dev_name] == dev}
      list[key] << {:dev_name  => dev, :results => []}
    end
  end 
end



