class Result
  include Models

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

class Metric
  attr_reader :name, :value, :timestamp

  def initialize(name, value, timestamp)
    @name = name
    @value = value
    @timestamp = timestamp
  end
end

class JmxMetricCollection
  attr_reader :gc_collection, :memorypool_collection, :memory_collection, :os_collection, :threading_collection

  def initialize
    @gc_collection = ['GarbageCollectorImpl.PSScavenge.CollectionTime','GarbageCollectorImpl.PSScavenge.CollectionCount','GarbageCollectorImpl.PSMarkSweep.CollectionTime','GarbageCollectorImpl.PSMarkSweep.CollectionCount']
    @memorypool_collection = ['MemoryPoolImpl.CodeCache.Usage_committed','MemoryPoolImpl.CodeCache.Usage_init','MemoryPoolImpl.CodeCache.Usage_max','MemoryPoolImpl.CodeCache.Usage_used']
    @memory_collection = ['MemoryImpl.HeapMemoryUsage_committed','MemoryImpl.HeapMemoryUsage_init','MemoryImpl.HeapMemoryUsage_max','MemoryImpl.HeapMemoryUsage_used','MemoryImpl.NonHeapMemoryUsage_committed','MemoryImpl.NonHeapMemoryUsage_init','MemoryImpl.NonHeapMemoryUsage_max','MemoryImpl.NonHeapMemoryUsage_used']
    @os_collection = ['UnixOperatingSystem.OpenFileDescriptorCount','UnixOperatingSystem.MaxFileDescriptorCount','UnixOperatingSystem.CommittedVirtualMemorySize','UnixOperatingSystem.TotalSwapSpaceSize','UnixOperatingSystem.FreeSwapSpaceSize','UnixOperatingSystem.ProcessCpuTime','UnixOperatingSystem.FreePhysicalMemorySize','UnixOperatingSystem.TotalPhysicalMemorySize','UnixOperatingSystem.SystemLoadAverage']
    @threading_collection = ['ThreadImpl.PeakThreadCount','ThreadImpl.DaemonThreadCount','ThreadImpl.ThreadCount','ThreadImpl.TotalStartedThreadCount'] 
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
