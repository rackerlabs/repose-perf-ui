class Application
  include Models
  attr_reader :id, :description, :name

  def initialize(id, name, description)
    @id = id
    @name = name
    @description = description
  end

end
