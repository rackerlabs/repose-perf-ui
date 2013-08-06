class PerfTest
  include Models

  attr_reader :id, :href, :name, :description

  def initialize(id, href, name, description)
    @id = id
    @href = href
    @name = name
    @description = description
  end
end
