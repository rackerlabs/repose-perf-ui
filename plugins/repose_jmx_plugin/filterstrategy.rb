require_relative 'abstractstrategy.rb'

class FilterStrategy < ReposeAbstractStrategy

  attr_accessor :average_metric_list,:detailed_metric_list 

  def initialize(name,test_type,id, config_path = nil)
    @average_metric_list = {
      "http-logging:Mean" => [],
      "dist-datastore:Mean" => [],
      "rate-limiting:Mean" => [],
      "http-logging:75thPercentile" => [],
      "dist-datastore:75thPercentile" => [],
      "rate-limiting:75thPercentile" => [],
      "route:75thPercentile" => [],
      "route:Mean" => [],
      "api-validator:75thPercentile" => [],
      "api-validator:Mean" => [],
      "client-auth:75thPercentile" => [],
      "client-auth:Mean" => [],
      "translation:75thPercentile" => [],
      "translation:Mean" => [],
      "content-normalization:Mean" => [],
      "content-normalization:75thPercentile" => [],
      "ip-identity:Mean" => [],
      "ip-identity:75thPercentile" => []
    }

    @detailed_metric_list = {
      "http-logging:75thPercentile" => [],
      "dist-datastore:75thPercentile" => [],
      "rate-limiting:75thPercentile" => [],
      "http-logging:Mean" => [],
      "dist-datastore:Mean" => [],
      "rate-limiting:Mean" => [],
      "route:75thPercentile" => [],
      "route:Mean" => [],
      "api-validator:75thPercentile" => [],
      "api-validator:Mean" => [],
      "client-auth:75thPercentile" => [],
      "client-auth:Mean" => [],
      "translation:75thPercentile" => [],
      "translation:Mean" => [],
      "content-normalization:Mean" => [],
      "content-normalization:75thPercentile" => [],
      "ip-identity:Mean" => [],
      "ip-identity:75thPercentile" => []
    }
    super(name,test_type,id,config_path)
  end 

  def populate_metric(entry, id, start, stop)
    Dir.glob("#{entry}/jmxdata.out*").each do |jmx_file|
      #execute file and get back io results
      File.open(jmx_file, 'r') do |file_handle|
        file_handle.each_line do |result|
          result.scan(/^localhost.*JmxReporter\$Timer\.(.*)\.(\w+)\s+(\d*\.?\d+?)\s+(\d+)$/).map do |metric,counter,value,timestamp|
            dev = "#{File.basename(jmx_file)}"
            initialize_metric(@detailed_metric_list,"#{metric}:#{counter}",dev)
            @detailed_metric_list["#{metric}:#{counter}"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => timestamp, :value => value}
          end 
        end
      end
    end
  end
end
