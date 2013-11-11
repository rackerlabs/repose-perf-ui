require_relative './../../Models/models.rb'

class AbstractStrategy
  include ResultModule

  attr_reader :folder_location

  def self.metric_description
    {}
  end

=begin
  TODO: move folder location to redis.  Rest remains the same
=end
  def initialize(name, test_type,id, config_path)
    config = config(config_path)
    test_type.chomp!("_test")
    @folder_location = "#{config['home_dir']}/files/apps/#{name}/results/#{test_type}"
    Dir.glob("#{folder_location}/tmp_*").each do |entry| 
      if File.directory?(entry)
        #get directory
        #get begin time, end time, tag name in entry meta file
#needs to take in options to split by repose vs origin
        json_file = JSON.parse(File.read("#{entry}/meta/#{test_type}_test.json")) if File.exists?("#{entry}/meta/#{test_type}_test.json")
#TODO: this is a hack for Repose only.  Please abstract to app-specific.
        if json_file['id'] == id && json_file['tag'].include?("with Repose")
          populate_metric(entry, id, json_file['start'], json_file['stop'])
          break
        end if json_file
      end
    end
  end

  def initialize_metric(list,key, dev, description = "")
    unless list[key].find{|key_data| key_data.has_key?(:dev_name) and key_data[:dev_name] == dev}
      list[key] << {:dev_name  => dev, :results => [], :description => description}
    end
  end 
end



