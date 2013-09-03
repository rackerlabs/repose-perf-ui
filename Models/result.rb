require 'json'
require 'yaml'
require_relative 'models.rb'

class Result

  attr_reader :date, :length, :avg, :throughput, :errors, :id, :tag

  def initialize(date, length, avg, throughput, errors, id, tag)
    @date = date
    @avg = avg
    @tag = tag
    @length = length
    @throughput = throughput
    @errors = errors
    @id = id
  end
end

class SummaryResult
  attr_reader :date, :throughput, :avg, :errors

  def initialize(date, throughput, avg, errors)
    @date = date
    @throughput = throughput
    @avg = avg
    @errors = errors
  end
end

class NetworkResult
  attr_reader :networkStrategy

  def initialize(networkStrategy)
    @networkStrategy = networkStrategy
  end

  def retrieve_detailed_results
    @networkStrategy.detailed_metric_list
  end

  def retrieve_average_results
    @networkStrategy.average_metric_list
  end
end

class AbstractStrategy
  include ResultModule

  attr_reader :folder_location
  def initialize(name, test_type,id, config_path = nil)
    config = config(config_path)
    test_type.chomp!("_test")
    @folder_location = "#{config['home_dir']}/files/apps/#{name}/results/#{test_type}"
    Dir.glob("#{folder_location}/tmp_*").each do |entry| 
      if File.directory?(entry)
        #get directory
        #get begin time, end time, tag name in entry meta file
        test_type = "load" if test_type == "adhoc"
        json_file = JSON.parse(File.read("#{entry}/meta/#{test_type}_test.json"))
        if json_file['id'] == id
          populate_metric(entry, id, json_file['start'], json_file['stop'])
          break
        end
      end
    end
  end
end

class DeviceDiskResultStrategy < AbstractStrategy
  def detailed_metric_list
    {
      "device" => [],
      "tps" => [],
      "rd_sec/s" => [],
      "wr_sec/s" => [],
      "avgrq-sz" => [],
      "avgqu-sz" => [],
      "await" => [],
      "svctm" => [],
      "%util" => []
    }
  end

  def average_metric_list
    {
      "device" => [],
      "tps" => [],
      "rd_sec/s" => [],
      "wr_sec/s" => [],
      "avgrq-sz" => [],
      "avgqu-sz" => [],
      "await" => [],
      "svctm" => [],
      "%util" => []
    }
  end

  def populate_metric(entry, id, start, stop)
    Dir.glob("#{entry}/sysstats.log*").each do |sysstats_file|
      #execute file and get back io results
      p "sar -b -f #{sysstats_file}"
      io_results = `sar -b -f #{sysstats_file}`

      (3..(io_results.length-2)).each do |index|
        io_results[index].scan(/(\d+:\d+:\d+ \w+)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)/).map do |time, tps, rtps,wtps,breads,bwrtns|
          #only use time that's between start and end (in the 24 hour period the time has to be between those 2)
          DeviceDiskResultStrategy.detailed_metric_list["tps"] << [time,tps]
          DeviceDiskResultStrategy.detailed_metric_list["rtps"] << [time,rtps]
          DeviceDiskResultStrategy.detailed_metric_list["wtps"] << [time,wtps]
          DeviceDiskResultStrategy.detailed_metric_list["bread/s"] << [time,breads]
          DeviceDiskResultStrategy.detailed_metric_list["bwrtn/s"] << [time,bwrtns]
        end
      end

      io_results[io_results.length-1].scan(/(\d+:\d+:\d+ \w+)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)/).map do |time, tps, rtps,wtps,breads,bwrtns|
        DeviceDiskResultStrategy.average_metric_list["tps"] = tps
        DeviceDiskResultStrategy.average_metric_list["rtps"] = rtps
        DeviceDiskResultStrategy.average_metric_list["wtps"] = wtps
        DeviceDiskResultStrategy.average_metric_list["bread/s"] = breads
        DeviceDiskResultStrategy.average_metric_list["bwrtn/s"] = bwrtns
      end
    end
  end
end

class DeviceNetworkResultStrategy < AbstractStrategy
  def detailed_metric_list
    {
      "IFACE" => [],
      "rxpck/s" => [],
      "txpck/s" => [],
      "rxkB/s" => [],
      "txkB/s" => [],
      "rxcmp/s" => [],
      "txcmp/s" => [],
      "rxmcst/s" => [],
      "rxerr/s" => [],
      "txerr/s" => [],
      "coll/s" => [],
      "rxdrop/s" => [],
      "txdrop/s" => [],
      "txcarr/s" => [],
      "rxfram/s" => [],
      "rxfifo/s" => [],
      "txfifo/s" => []
    }
  end

  def average_metric_list
    {
      "IFACE" => [],
      "rxpck/s" => [],
      "txpck/s" => [],
      "rxkB/s" => [],
      "txkB/s" => [],
      "rxcmp/s" => [],
      "txcmp/s" => [],
      "rxmcst/s" => [],
      "rxerr/s" => [],
      "txerr/s" => [],
      "coll/s" => [],
      "rxdrop/s" => [],
      "txdrop/s" => [],
      "txcarr/s" => [],
      "rxfram/s" => [],
      "rxfifo/s" => [],
      "txfifo/s" => []
    }
  end
end

class SocketNetworkResultStrategy < AbstractStrategy
  def detailed_metric_list
    {
      "totsck" => [],
      "tcpsck" => [],
      "udpsck" => [],
      "rawsck" => [],
      "ip-frag" => [],
      "tcp-tw" => []
    }
  end

  def average_metric_list
    {
      "totsck" => [],
      "tcpsck" => [],
      "udpsck" => [],
      "rawsck" => [],
      "ip-frag" => [],
      "tcp-tw" => []
    }
  end
end

class IOTransferResultStrategy < AbstractStrategy
  attr_reader :test_list

  def detailed_metric_list
    {
      "time" => [],
      "tps" => [],
      "rtps" => [],
      "wtps" => [],
      "bread/s" => [],
      "bwrtn/s" => []
    }
  end

  def average_metric_list
    {
      "tps" => "",
      "rtps" => "",
      "wtps" => "",
      "bread/s" => "",
      "bwrtn/s" => ""
    }
  end

  def populate_metric(entry, id, start, stop)
    Dir.glob("#{entry}/sysstats.log*").each do |sysstats_file|
      #execute file and get back io results
      io_results = `sar -b -f #{sysstats.log}`

      (3..(io_results.length-2)).each do |index|
        io_results[index].scan(/(\d+:\d+:\d+ \w+)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)/).map do |time, tps, rtps,wtps,breads,bwrtns|
          #only use time that's between start and end (in the 24 hour period the time has to be between those 2)
          IOResultStrategy.detailed_metric_list["tps"] << [time,tps]
          IOResultStrategy.detailed_metric_list["rtps"] << [time,rtps]
          IOResultStrategy.detailed_metric_list["wtps"] << [time,wtps]
          IOResultStrategy.detailed_metric_list["bread/s"] << [time,breads]
          IOResultStrategy.detailed_metric_list["bwrtn/s"] << [time,bwrtns]
        end
      end

      io_results[io_results.length-1].scan(/(\d+:\d+:\d+ \w+)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)/).map do |time, tps, rtps,wtps,breads,bwrtns|
        IOResultStrategy.average_metric_list["tps"] = tps
        IOResultStrategy.average_metric_list["rtps"] = rtps
        IOResultStrategy.average_metric_list["wtps"] = wtps
        IOResultStrategy.average_metric_list["bread/s"] = breads
        IOResultStrategy.average_metric_list["bwrtn/s"] = bwrtns
      end
    end
  end
end


class DiskPagingResultStrategy
  attr_reader :test_list

  def self.detailed_metric_list
    {
      "time" => [],
      "pgpgin/s" => [],
      "pgpgout/s" => [],
      "fault/s" => [],
      "majflt/s" => [],
      "pgfree/s" => [],
      "pgscank/s" => [],
      "pgscand/s" => [],
      "pgsteal/s" => [],
      "%vmeff" => []
    }
  end

  def self.average_metric_list
    {
      "pgpgin/s" => "",
      "pgpgout/s" => "",
      "fault/s" => "",
      "majflt/s" => "",
      "pgfree/s" => "",
      "pgscank/s" => "",
      "pgscand/s" => "",
      "pgsteal/s" => "",
      "%vmeff" => ""
    }
  end

  def populate_metric(entry, id, start, stop)
    Dir.glob("#{entry}/sysstats.log*").each do |sysstats_file|
      #execute file and get back io results
      io_results = `sar -Bd -f #{sysstats.log}`

      (3..(io_results.length-2)).each do |index|
        io_results[index].scan(/(\d+:\d+:\d+ \w+)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)/).map do |time, tps, rtps,wtps,breads,bwrtns|
          DiskPagingResultStrategy.detailed_metric_list["tps"] << [time,tps]
          DiskPagingResultStrategy.detailed_metric_list["rtps"] << [time,rtps]
          DiskPagingResultStrategy.detailed_metric_list["wtps"] << [time,wtps]
          DiskPagingResultStrategy.detailed_metric_list["bread/s"] << [time,breads]
          DiskPagingResultStrategy.detailed_metric_list["bwrtn/s"] << [time,bwrtns]
        end
      end

      io_results[io_results.length-1].scan(/(\d+:\d+:\d+ \w+)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)\s+(\d+\.?\d+?)/).map do |time, tps, rtps,wtps,breads,bwrtns|
        DiskPagingResultStrategy.average_metric_list["tps"] = tps
        DiskPagingResultStrategy.average_metric_list["rtps"] = rtps
        DiskPagingResultStrategy.average_metric_list["wtps"] = wtps
        DiskPagingResultStrategy.average_metric_list["bread/s"] = breads
        DiskPagingResultStrategy.average_metric_list["bwrtn/s"] = bwrtns
      end
    end
  end
end