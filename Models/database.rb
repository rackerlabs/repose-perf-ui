require 'sqlite3'

class Database
  attr_accessor :apps
  attr_accessor :version
  attr_reader :db

  def initialize
    @db = SQLite3::Database.new("performance.db")
  end

  def upgrade(version_id)
    @version = version_id
    @db.execute("drop table IF EXISTS applications")
    @db.execute("create table applications (id INTEGER PRIMARY KEY AUTOINCREMENT, app_id TEXT UNIQUE NOT NULL, name TEXT UNIQUE NOT NULL, description TEXT)")
    @db.results_as_hash = true
  end

  def load_apps(app_list)
    app_list.each do |key, value|
      @db.execute "insert into applications (app_id, name, description) values (?,?,?)",key.to_s, value.name, value.description 
    end if app_list
  end

  def retrieve_apps
    applications = {}
    @db.execute "select * from applications" do |row|
       p row.inspect
       applications.merge!({row['app_id'].to_sym => Application.new(row['id'], row['name'], row['description'])})
    end    
    p applications.inspect
    applications
  end

  def remove_record(table, where_list)

  end

  def update_record(table, record, where_list)

  end

  def clear_list(table)

  end
end
