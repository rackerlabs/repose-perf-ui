module SnapshotComparer
  module Models
    class ApplicationTestType
      def self.FAILED 
        "failed"
      end
     
      def self.PASSED
        "passed"
      end
     
      attr_reader :store

      def initialize(store = nil, login_hash = nil)
        puts "initialization logic in application test type: #{store}, #{login_hash}"
        @store = store
        @store = Redis.new(login_hash) if login_hash
      end

      def save(application, sub_app, test_type, guid, status)
        puts "store: #{@store}"
        puts "save the status: #{application}, #{sub_app}, #{test_type}, #{guid}, #{status}"
        @store.set("#{application}:#{sub_app}:results:#{test_type}:#{guid}:status", status)
        @store.hset("#{application}:#{sub_app}:results:status", test_type, status)
      end
 
      def get_overall_status(application, sub_app)
        results = @store.hgetall("#{application}:#{sub_app}:results:status")
        results.each do |key, value|
          return ApplicationTestType.FAILED if value == ApplicationTestType.FAILED
        end
        return ApplicationTestType.PASSED
      end

      def get_status_for_type(application, sub_app, test_type)
        puts "test type: #{test_type}", @store.hget("#{application}:#{sub_app}:results:status", test_type)
        type = test_type.chomp("_test")
        return @store.hget("#{application}:#{sub_app}:results:status", type)
      end

      def get_status_for_guid(application, sub_app, test_type, guid)
        type = test_type.chomp("_test")
        status = @store.get("#{application}:#{sub_app}:results:#{type}:#{guid}:status")
        status ||= :passed
        status
      end
       
    end
  end
end
