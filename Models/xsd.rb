module XSD
	class Element
	  attr_accessor :parent, :children, :attributes, :is_required, :type, :output, :name, :description, :collection_type, :default, :extension

	  def load
	    @output = {}
	    @output[:name] = @name
	    @output[:description] = @description
	    @output[:children] = @children.map {|child| {:name => child.name, :is_required => child.is_required, :type => child.type, :description => child.description } }
	    @output[:attributes] = @attributes
	    @output[:is_required] = @is_required
	    @output[:type] = @type
	    @output
	  end

	  def initialize(name, description = nil, is_required = false, type = :string, collection_type = nil, default = nil, extension = nil)
	    @is_required = is_required
	    @type = type
	    @name = name
	    @description = description
	    @parent = nil
	    @children = []
	    @attributes = []
	    @collection_type = collection_type
	    @default = default
	    @extension = extension
	  end
	end

	class Attribute
	  attr_accessor :is_required, :type, :name, :extension, :description

	  def initialize(name, description, is_required = false, type = :string, extension = nil)
	    @is_required = is_required
	    @type = type
	    @name = name
	    @extension = extension
	    @description = description
	  end
	end
end