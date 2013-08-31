require './tests/Models/test_helper.rb'
require  './Models/testlocation.rb'

class TestLocationTest < Test::Unit::TestCase
	def test_initialize
		testlocation = Models::TestLocation.new(1,2,3)
		assert_not_nil(testlocation, "testlocation construction failed")
		assert_equal(1, testlocation.href)
		assert_equal(2, testlocation.type)
		assert_equal(3, testlocation.test_location_dir)		
	end

	def test_download
		testlocation = Models::TestLocation.new(1,2,3)
		assert_not_nil(testlocation, "testlocation construction failed")
		download = testlocation.download
		assert_equal("3/1", download)
	end


end

class TestLocationFactoryTest < Test::Unit::TestCase
	def setup
		@config = YAML.load_file(File.expand_path("../../../config/config.yaml", __FILE__))
	end

	def test_get_by_name
		test = Models::TestLocationFactory.get_by_name("unit_test")
		assert_not_nil(test, "Test construction failed.")
		assert_equal("test_custom.jmx",test.href)
		assert_equal(:jmeter,test.type)
		assert_equal("/Users/dimi5963/projects/repose_pt/files/apps/unit_test/tests/setup/main",test.test_location_dir)
	end

	def test_get_by_name_app_name_dne
		assert_raise ArgumentError do
			test = Models::TestLocationFactory.get_by_name("unit_test_dne")
		end
	end

	def test_get_by_name_no_tests_dir
		assert_raise ArgumentError do
			test = Models::TestLocationFactory.get_by_name("unit_test_no_tests_dir")
		end
	end

	def test_get_by_name_no_setup_dir
		assert_raise ArgumentError do
			test = Models::TestLocationFactory.get_by_name("unit_test_no_setup_dir")
		end
	end

	def test_get_by_name_no_main_dir
		assert_raise ArgumentError do
			test = Models::TestLocationFactory.get_by_name("unit_test_no_main_dir")
		end
	end

	def test_get_by_name_no_test_file
		assert_raise ArgumentError do
			test = Models::TestLocationFactory.get_by_name("unit_test_no_test_file")
		end
	end

	def test_get_by_name_unknown_test_file
		assert_raise ArgumentError do
			test = Models::TestLocationFactory.get_by_name("unit_test_unknown_test_file")
		end
	end

	def test_get_by_file_location
		test = Models::TestLocationFactory.get_by_file_location("#{@config['home_dir']}/files/apps/unit_test/results/adhoc/current")
		assert_not_nil(test, "Test construction failed.")
		assert_equal("test_custom.jmx",test.href)
		assert_equal(:jmeter,test.type)
		assert_equal("/Users/dimi5963/projects/repose_pt/files/apps/unit_test/results/adhoc/current/meta",test.test_location_dir)
	end

	def test_get_by_file_location_location_dne
		assert_raise ArgumentError do
			test = Models::TestLocationFactory.get_by_file_location("#{@config['home_dir']}/files/apps/unit_test_dne/results/adhoc/current")
		end
	end

	def test_get_by_file_location_no_result_dir
		assert_raise ArgumentError do
			test = Models::TestLocationFactory.get_by_file_location("#{@config['home_dir']}/files/apps/unit_test_no_result_dir/results/adhoc/current")
		end
	end

	def test_get_by_file_location_no_test_type_dir
		assert_raise ArgumentError do
			test = Models::TestLocationFactory.get_by_file_location("#{@config['home_dir']}/files/apps/unit_test_no_result_adhoc_dir/results/adhoc/current")
		end
	end

	def test_get_by_file_location_no_test_instance_dir
		assert_raise ArgumentError do
			test = Models::TestLocationFactory.get_by_file_location("#{@config['home_dir']}/files/apps/unit_test_no_result_current_dir/results/adhoc/current")
		end
	end

	def test_get_by_file_location_no_meta_dir
		assert_raise ArgumentError do
			test = Models::TestLocationFactory.get_by_file_location("#{@config['home_dir']}/files/apps/unit_test_no_config_dir/results/adhoc/current")
		end
	end
	def test_get_by_file_location_no_test_file
		assert_raise ArgumentError do
			test = Models::TestLocationFactory.get_by_file_location("#{@config['home_dir']}/files/apps/unit_test_no_test_file/results/adhoc/current")
		end
	end

	def test_get_by_file_location_unknown_test_file
		assert_raise ArgumentError do
			test = Models::TestLocationFactory.get_by_file_location("#{@config['home_dir']}/files/apps/unit_test_unknown_test_file/results/adhoc/current")
		end
	end
end
