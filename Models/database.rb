require 'sqlite3'
require 'pg'
require 'yaml'

module SnapshotComparer
module Models
  class Database

    attr_accessor :apps
    attr_accessor :version
    attr_reader :db

    def initialize(name = nil)
      name = "performance" unless name
      @db = SQLite3::Database.new("#{name}.db")
    end

    def upgrade(version_id = 1)
      @version = version_id
      @db.execute("drop table IF EXISTS applications")
      @db.execute("create table applications (id INTEGER PRIMARY KEY AUTOINCREMENT, app_id TEXT UNIQUE NOT NULL, name TEXT UNIQUE NOT NULL, description TEXT)")
      @db.results_as_hash = true
    end

    def load_apps(app_list = {})
      app_list.each do |key, value|
        @db.execute "insert into applications (app_id, name, description) values (?,?,?)",key.to_s, value.name, value.description
      end if app_list
    end

    def retrieve_apps
      applications = {}
      @db.execute "select * from applications" do |row|
         applications.merge!({row['app_id'].to_sym => Models::Application.new(row['id'], row['name'], row['description'])})
      end
      applications
    end
  end

  class PostgresDatabase
    attr_reader :conn

    def initialize(config_path)
      config_path ||= File.expand_path("config/config.yaml", Dir.pwd)
      @config = YAML.load_file(config_path)
puts @config.inspect
      @conn = PGconn.connect(dbname: @config['postgres']['db'],user: @config['postgres']['user'], password: @config['postgres']['password'], host: @config['postgres']['host'])
    end

    def get_slas(app, sub_app, test_type)

    end

    def get_slas_by_id(guid)

    end

    def get_moving_average(app, sub_app, test_type)
    end

    def does_test_fail_sla(guid, sla, sla_type)
=begin
  get sla type (passed in as object)
  get value from sla (sla_type.current_threshold)
  based on sla threshold (from config) check if value is <> the sla
  return true or false
=end

    end
  end
end
end
