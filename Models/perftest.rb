module Models
	class PerfTest
	  attr_reader :id, :name, :description

	  def initialize(id, name, description)
	    @id = id
	    @name = name
	    @description = description
	  end
	end
end