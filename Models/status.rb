module SnapshotComparer
  module Models
    class Status
      def get_status_list(db, fs_ip, app, sub_app, type)
        store = Redis.new(db)
        begin
          store.get("#{app}:#{sub_app}
