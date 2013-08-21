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

class SummaryResult
  attr_reader :date, :throughput, :avg, :errors

  def initialize(date, throughput, avg, errors)
    @date = date
    @throughput = throughput
    @avg = avg
    @errors = errors
  end
end
