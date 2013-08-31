require './tests/Models/test_helper.rb'
require  './Models/configuration.rb'

class ConfigurationTest < Test::Unit::TestCase
	def setup
		@config = YAML.load_file(File.expand_path("../../../config/config.yaml", __FILE__))
	end

	def test_get_by_location
		configuration = Models::Configuration.new.get_by_result_file_location("#{@config['home_dir']}/files/apps/unit_test/results/adhoc/current")
		assert_not_nil(configuration, "Configuration construction failed.")
		assert(configuration.keys.include?(:client_auth_n_cfg_xml))
		assert(configuration.keys.include?(:container_cfg_xml))
		assert(configuration.keys.include?(:http_connection_pool_cfg_xml))
		assert(configuration.keys.include?(:openstack_authorization_cfg_xml))
		assert(configuration.keys.include?(:response_messaging_cfg_xml))
		assert(configuration.keys.include?(:system_model_cfg_xml))
	end

	def test_get_by_file_location_location_dne
		configuration = Models::Configuration.new.get_by_result_file_location("#{@config['home_dir']}/files/apps/unit_test_dne/results/adhoc/current")
		assert_not_nil(configuration, "Configuration construction failed.")
		assert_equal({},configuration)
	end

	def test_get_by_file_location_no_result_dir
		configuration = Models::Configuration.new.get_by_result_file_location("#{@config['home_dir']}/files/apps/unit_test_no_result_dir/results/adhoc/current")
		assert_not_nil(configuration, "Configuration construction failed.")
		assert_equal({},configuration)
	end

	def test_get_by_file_location_no_test_type_dir
		configuration = Models::Configuration.new.get_by_result_file_location("#{@config['home_dir']}/files/apps/unit_test_no_result_adhoc_dir/results/adhoc/current")
		assert_not_nil(configuration, "Configuration construction failed.")
		assert_equal({},configuration)
	end

	def test_get_by_file_location_no_test_instance_dir
		configuration = Models::Configuration.new.get_by_result_file_location("#{@config['home_dir']}/files/apps/unit_test_no_result_current_dir/results/adhoc/current")
		assert_not_nil(configuration, "Configuration construction failed.")
		assert_equal({},configuration)
	end

	def test_get_by_file_location_no_config_dir
		configuration = Models::Configuration.new.get_by_result_file_location("#{@config['home_dir']}/files/apps/unit_test_no_config_dir/results/adhoc/current")
		assert_not_nil(configuration, "Configuration construction failed.")
		assert_equal({},configuration)
	end

	def test_get_by_file_location_no_xml_files
		configuration = Models::Configuration.new.get_by_result_file_location("#{@config['home_dir']}/files/apps/unit_test_empty_config_dir/results/adhoc/current")
		assert_not_nil(configuration, "Configuration construction failed.")
		assert_equal({},configuration)
	end

	def test_get_by_name
		configuration = Models::Configuration.new.get_by_name("unit_test")
		assert_not_nil(configuration, "Configuration construction failed.")
		assert(configuration.keys.include?(:client_auth_n_cfg_xml))
		assert(configuration.keys.include?(:container_cfg_xml))
		assert(configuration.keys.include?(:http_connection_pool_cfg_xml))
		assert(configuration.keys.include?(:openstack_authorization_cfg_xml))
		assert(configuration.keys.include?(:response_messaging_cfg_xml))
		assert(configuration.keys.include?(:system_model_cfg_xml))
	end

	def test_get_by_name_no_name
		configuration = Models::Configuration.new.get_by_name(nil)
		assert_not_nil(configuration, "Configuration construction failed.")
		assert_equal({},configuration)
	end

	def test_get_by_name_name_dne
		configuration = Models::Configuration.new.get_by_name("unit_test_dne")
		assert_not_nil(configuration, "Configuration construction failed.")
		assert_equal({},configuration)
	end

	def test_get_by_name_no_config_dir
		configuration = Models::Configuration.new.get_by_name("unit_test_no_config_dir")
		assert_not_nil(configuration, "Configuration construction failed.")
		assert_equal({},configuration)
	end

	def test_get_by_name_no_main_dir
		configuration = Models::Configuration.new.get_by_name("unit_test_empty_config_dir")
		assert_not_nil(configuration, "Configuration construction failed.")
		assert_equal({},configuration)
	end

	def test_get_by_name_no_xml_files
		configuration = Models::Configuration.new.get_by_name("unit_test_empty_main_config_dir")
		assert_not_nil(configuration, "Configuration construction failed.")
		assert_equal({},configuration)
	end

end