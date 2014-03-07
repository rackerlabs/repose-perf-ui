require_relative 'abstractstrategy.rb'

module FilePluginModule
  class FileBlobStrategy < FilePluginModule::AbstractStrategy

    attr_accessor :average_metric_list,:detailed_metric_list

    def self.metric_description
      {
      }
    end

    def initialize(db, fs_ip, application, name, test_type, id, metric_id, offset, size, find_criteria = nil)
      @average_metric_list = {}

      @detailed_metric_list = {}
      super(db, fs_ip, application, name, test_type, id, metric_id, offset, size, find_criteria)
    end

    def populate_metric(entry, name, id, offset, size, find_criteria)
      file_size = 0
      if find_criteria
        output = open(entry) do |f|
          file_size = f.size
          f.each_line.find_all {
            |line| /#{Regexp.escape(find_criteria)}/.match(line)
          }
        end
      else
        output = open(entry) do |f|
          file_size = f.size
          offset ||= 0
          f.seek offset.to_i
          if size
            f.read size.to_i
          else
            f.read
          end
        end
      end
      @average_metric_list[id] = [] unless @average_metric_list[id]
      metric_list = @average_metric_list[id].find {|m| m[:dev_name] == name }
      if metric_list
        metric_list.merge!({:dev_name => name, :results => output, :size => file_size, :chunk => size, :offset => offset})
      else
        @average_metric_list[id] << {:dev_name => name, :results => output, :size => file_size, :chunk => size, :offset => offset}
      end 
    end
  end
end
