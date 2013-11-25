require_relative 'abstractstrategy.rb'

class FilterStrategy < ReposeAbstractStrategy

  attr_accessor :average_metric_list,:detailed_metric_list 

  def initialize(db, fs_ip, application, name, test_type, id)
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
    super(db, fs_ip, application, name, test_type, id)
  end 

  def populate_metric(entry, name, id, start, stop)
    open(entry).readlines.each do |line|
      line.scan(/^localhost.*JmxReporter\$Timer\.(.*)\.(\w+)\s+(\d*\.?\d+?)\s+(\d+)$/).map do |metric, counter, value, timestamp|
        initialize_metric(@detailed_metric_list,"#{metric}:#{counter}", name)
        @detailed_metric_list["#{metric}:#{counter}"].find {|key_data| key_data[:dev_name] == name}[:results] << {:time => timestamp, :value => value}
      end
    end
    @detailed_metric_list.each do |key, v|
      initialize_metric(@average_metric_list, key, name)
      v.each do | dev_name_entry |
        average_results = dev_name_entry[:results].map {|result| result[:value].to_f}
        average = average_results.inject(:+).to_f / average_results.length
        @average_metric_list[key].find {|key_data| key_data[:dev_name] == name}[:results] = average
      end
    end
  end
end
