require_relative 'abstractstrategy.rb'

module ReposeJmxPluginModule
  class FilterStrategy < ReposeJmxPluginModule::AbstractStrategy

    attr_accessor :average_metric_list,:detailed_metric_list

    def self.metric_description
      {
        "http-logging:75thPercentile" => "",
        "dist-datastore:75thPercentile" => "",
        "rate-limiting:75thPercentile" => "",
        "route:75thPercentile" => "",
        "api-validator:75thPercentile" => "",
        "client-auth:75thPercentile" => "",
        "translation:75thPercentile" => "",
        "content-normalization:Mean" => "",
        "content-normalization:75thPercentile" => "",
        "ip-identity:75thPercentile" => "",
        "default-router:75thPercentile" => "",
        "compression:75thPercentile" => ""
      }
    end

    def initialize(db, fs_ip, application, name, test_type, id, metric_id)
      @average_metric_list = {
        "http-logging:75thPercentile" => [],
        "dist-datastore:75thPercentile" => [],
        "rate-limiting:75thPercentile" => [],
        "route:75thPercentile" => [],
        "api-validator:75thPercentile" => [],
        "client-auth:75thPercentile" => [],
        "translation:75thPercentile" => [],
        "content-normalization:Mean" => [],
        "content-normalization:75thPercentile" => [],
        "ip-identity:75thPercentile" => [],
        "default-router:75thPercentile" => [],
        "compression:75thPercentile" => []
      }

      @detailed_metric_list = {
        "http-logging:75thPercentile" => [],
        "dist-datastore:75thPercentile" => [],
        "rate-limiting:75thPercentile" => [],
        "route:75thPercentile" => [],
        "api-validator:75thPercentile" => [],
        "client-auth:75thPercentile" => [],
        "translation:75thPercentile" => [],
        "content-normalization:Mean" => [],
        "content-normalization:75thPercentile" => [],
        "ip-identity:75thPercentile" => [],
        "default-router:75thPercentile" => [],
        "compression:75thPercentile" => []
      }
      super(db, fs_ip, application, name, test_type, id, metric_id)
    end

    def populate_metric(entry, name, id, start, stop)
      open(entry).readlines.each do |line|
        line.scan(/^localhost.*JmxReporter\$Timer\.(.*)\.(\w+)\s+(\d*\.?\d+?)\s+(\d+)$/).map do |metric, counter, value, timestamp|
          if(@detailed_metric_list["#{metric}:#{counter}"])
            initialize_metric(@detailed_metric_list,"#{metric}:#{counter}", name)
            @detailed_metric_list["#{metric}:#{counter}"].find {|key_data| key_data[:dev_name] == name}[:results] << {:time => timestamp, :value => value}
          end
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
end
