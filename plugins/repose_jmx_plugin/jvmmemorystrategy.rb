require_relative 'abstractstrategy.rb'

class JvmMemoryStrategy < ReposeAbstractStrategy

  attr_accessor :average_metric_list,:detailed_metric_list 
  def initialize(name,test_type,id, config_path = nil)
    @average_metric_list = {
      "HeapMemoryUsage.committed" => [],
      "HeapMemoryUsage.used" => [],
      "HeapMemoryUsage.max" => [],
      "HeapMemoryUsage.init" => []
    }

    @detailed_metric_list = {
      "HeapMemoryUsage.committed" => [],
      "HeapMemoryUsage.used" => [],
      "HeapMemoryUsage.max" => [],
      "HeapMemoryUsage.init" => []
    }
    super(name,test_type,id,config_path)
  end 

  def populate_metric(entry, id, start, stop)
    Dir.glob("#{entry}/jmxdata.out*").each do |jmx_file|
      #execute file and get back io results
      File.open(jmx_file, 'r') do |file_handle|
        file_handle.each_line do |result|
          result.scan(/^localhost.*sun_management_MemoryImpl\.HeapMemoryUsage_(\w+)\s+(\d*\.?\d*?)\s+(\d+)$/).map do |counter,value,timestamp|
            dev = "#{File.basename(jmx_file)}"
            initialize_metric(@detailed_metric_list,"HeapMemoryUsage.#{counter}",dev)
            @detailed_metric_list["HeapMemoryUsage.#{counter}"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => timestamp, :value => value}
          end 
        end
      end
    end
  end
end
