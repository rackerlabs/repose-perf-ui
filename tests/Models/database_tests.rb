require './tests/Models/test_helper.rb'
require  './Models/database.rb'

class DatabaseTest < Test::Unit::TestCase
	def test_initialize
		database = Models::Database.new
		assert_not_nil(database, "Database construction failed")
	end

	def test_initialize_with_diff_name
		database = Models::Database.new "new_db"
		assert_not_nil(database, "Database construction failed")
	end

	def test_upgrade
		database = Models::Database.new
		assert_not_nil(database, "Database construction failed")
		database.upgrade(1)
		assert_equal(true,database.db.results_as_hash)
	end

	def test_upgrade_version_not_specified
		database = Models::Database.new
		assert_not_nil(database, "Database construction failed")
		database.upgrade
		assert_equal(true,database.db.results_as_hash)
	end

	def test_upgrade_new_database
		database = Models::Database.new "new_db"
		assert_not_nil(database, "Database construction failed")
		database.upgrade
		assert_equal(true,database.db.results_as_hash)
	end

	def test_load_apps
		app_list = {
			:app1 => Models::Application.new(:app1,'app1','desc1'),
			:app2 => Models::Application.new(:app2,'app2','desc2'),
			:app3 => Models::Application.new(:app3,'app3','desc3'),
			:app4 => Models::Application.new(:app4,'app4','desc4')
		}
		database = Models::Database.new
		assert_not_nil(database, "Database construction failed")
		database.upgrade
		database.load_apps app_list
	end

	def test_load_apps_empty_app_list
		database = Models::Database.new
		assert_not_nil(database, "Database construction failed")
		database.upgrade
		database.load_apps []
	end

	def test_load_apps_no_app_list
		database = Models::Database.new
		assert_not_nil(database, "Database construction failed")
		database.upgrade
		database.load_apps 
	end

	def test_retrieve_apps
		app_list = {
			:app1 => Models::Application.new(:app1,'app1','desc1'),
			:app2 => Models::Application.new(:app2,'app2','desc2'),
			:app3 => Models::Application.new(:app3,'app3','desc3'),
			:app4 => Models::Application.new(:app4,'app4','desc4')
		}
		database = Models::Database.new
		assert_not_nil(database, "Database construction failed")
		database.upgrade
		database.load_apps app_list
		apps = database.retrieve_apps
		assert_equal(4, apps.keys.length)
		assert_equal([:app1,:app2,:app3,:app4], apps.keys)
		apps.each do |key,value| 
			assert_equal(key, value.name.to_sym)
			assert_not_nil(value.id)
		end
	end

	def test_retrieve_apps_no_apps
		database = Models::Database.new
		assert_not_nil(database, "Database construction failed")
		database.upgrade
		apps = database.retrieve_apps
		assert_equal({}, apps)
	end

end