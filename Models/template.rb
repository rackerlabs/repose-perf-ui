module SnapshotComparer
class Template
  attr_accessor :template

  def render
    ERB.new(@template).result(binding)
  end
end

class SystemModelTemplate < Template
  attr_reader :nodes

  def initialize(nodes, template)
    @nodes = nodes
    @template = template
  end
end

class TestTemplate < Template
  attr_reader :start_time, :stop_time, :tag, :test_type

  def initialize(start_time, end_time, tag, id, test_type, template)
    @start_time = start_time
    @stop_time = end_time
    @template = template
    @tag = tag
    @id = id
    @test_type = test_type
  end
end

class JmeterTemplate < Template
  attr_reader :start_time, :end_time, :threads, :ramp_time, :host

  def initialize(start_time, end_time, threads, ramp_time, host, template)
    @start_time = start_time
    @end_time = end_time
    @threads = threads
    @ramp_time = ramp_time
    @host = host
    @template = template
  end
end
end
