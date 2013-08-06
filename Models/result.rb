class Result
  include Models

  attr_reader :date, :art, :network, :cpu, :memory, :disk

  def initialize(date, art, network, cpu, memory,disk)
    @date = date
    @art = art
    @network = network
    @cpu = cpu
    @memory = memory
    @disk = disk
  end
end
    
