module Models
	class Application
	  attr_reader :id, :description, :name

	  attr_accessor :app_id, :request_response_list, :config_list, :detailed_results
	  attr_accessor :test_location, :load_test_list, :results, :result_set_list, :test_type
	  attr_accessor :date, :test_id, :compared_result_set_list

	  def initialize(id, name, description)
	    @id = id
	    @name = name
	    @description = description
	  end

	end
end