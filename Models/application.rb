class Application
  include Models
  attr_reader :id, :href, :description, :name

  def initialize(id, href, name, description)
    @id = id
    @href = href
    @name = name
    @description = description
  end

end
