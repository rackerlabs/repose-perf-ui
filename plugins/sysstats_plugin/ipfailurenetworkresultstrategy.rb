require_relative 'abstractstrategy.rb'

class IpFailureNetworkResultStrategy < AbstractStrategy
  attr_accessor :average_metric_list,:detailed_metric_list 

  def self.metric_description
    {
      "ihdrerr/s" => "",
      "iadrerr/s" => "",
      "iukwnpr/s" => "",
      "idisc/s" => "",
      "odisc/s" => "",
      "onort/s" => "",
      "fragok/s" => "",
      "fragf/s" => ""
    }
  end

  def initialize(db, fs_ip, application, name, test_type, id)
    @average_metric_list = {
      "ihdrerr/s" => [],
      "iadrerr/s" => [],
      "iukwnpr/s" => [],
      "idisc/s" => [],
      "odisc/s" => [],
      "onort/s" => [],
      "fragok/s" => [],
      "fragf/s" => []
    }

    @detailed_metric_list = {
      "ihdrerr/s" => [],
      "iadrerr/s" => [],
      "iukwnpr/s" => [],
      "idisc/s" => [],
      "odisc/s" => [],
      "onort/s" => [],
      "fragok/s" => [],
      "fragf/s" => []
    }
    super(db, fs_ip, application, name, test_type, id)
  end 

  def populate_metric(entry, name, id, start, stop)
    open(entry).readlines.each do |result|
      result.scan(/Average:\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)$/).map do |ihdrerrs,iadrerrs,iukwnprs,idiscs,odiscs,onorts,fragoks,fragfs|
        #get device name and then time
        #only use time that's between start and end (in the 24 hour period the time has to be between those 2)
        dev = File.basename(entry)
        initialize_metric(@average_metric_list,"ihdrerr/s",dev)
        @average_metric_list["ihdrerr/s"].find {|key_data| key_data[:dev_name] == dev}[:results] = ihdrerrs
        initialize_metric(@average_metric_list,"iadrerr/s",dev)
        @average_metric_list["iadrerr/s"].find {|key_data| key_data[:dev_name] == dev}[:results] = iadrerrs
        initialize_metric(@average_metric_list,"iukwnpr/s",dev)
        @average_metric_list["iukwnpr/s"].find {|key_data| key_data[:dev_name] == dev}[:results] = iukwnprs
        initialize_metric(@average_metric_list,"idisc/s",dev)
        @average_metric_list["idisc/s"].find {|key_data| key_data[:dev_name] == dev}[:results] = idiscs
        initialize_metric(@average_metric_list,"odisc/s",dev)
        @average_metric_list["odisc/s"].find {|key_data| key_data[:dev_name] == dev}[:results] = odiscs
        initialize_metric(@average_metric_list,"onort/s",dev)
        @average_metric_list["onort/s"].find {|key_data| key_data[:dev_name] == dev}[:results] = onorts
        initialize_metric(@average_metric_list,"fragok/s",dev)
        @average_metric_list["fragok/s"].find {|key_data| key_data[:dev_name] == dev}[:results] = fragoks
        initialize_metric(@average_metric_list,"fragf/s",dev)
        @average_metric_list["fragf/s"].find {|key_data| key_data[:dev_name] == dev}[:results] = fragfs
      end
      result.scan(/(\d+:\d+:\d+ \S+)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)\s+(\d+\.?\d*?)$/).map do |time,ihdrerrs,iadrerrs,iukwnprs,idiscs,odiscs,onorts,fragoks,fragfs|
        #get device name and then time
        #only use time that's between start and end (in the 24 hour period the time has to be between those 2)
        dev = File.basename(entry)
        initialize_metric(@detailed_metric_list,"ihdrerr/s",dev)
        @detailed_metric_list["ihdrerr/s"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value => ihdrerrs}
        initialize_metric(@detailed_metric_list,"iadrerr/s",dev)
        @detailed_metric_list["iadrerr/s"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value => iadrerrs}
        initialize_metric(@detailed_metric_list,"iukwnpr/s",dev)
        @detailed_metric_list["iukwnpr/s"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value => iukwnprs}
        initialize_metric(@detailed_metric_list,"idisc/s",dev)
        @detailed_metric_list["idisc/s"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value => idiscs}
        initialize_metric(@detailed_metric_list,"odisc/s",dev)
        @detailed_metric_list["odisc/s"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value => odiscs}
        initialize_metric(@detailed_metric_list,"onort/s",dev)
        @detailed_metric_list["onort/s"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value => onorts}
        initialize_metric(@detailed_metric_list,"fragok/s",dev)
        @detailed_metric_list["fragok/s"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value => fragoks}
        initialize_metric(@detailed_metric_list,"fragf/s",dev)
        @detailed_metric_list["fragf/s"].find {|key_data| key_data[:dev_name] == dev}[:results] << {:time => time, :value => fragfs}
      end
    end
  end
end
