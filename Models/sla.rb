module SnapshotComparer
  module Models
    class Sla
      attr_reader :limit, :value, :value_type, :test_list, :name

      def initialize(name, value, limit = :upper, value_type = :int, test_list = :load)
        @limit = limit
        @value = value
        @value_type = value_type
        @test_list = test_list
        @name = name
      end

      def self.result_failed_sla(sla, test_result, test_type)
        puts "result:",sla.test_list, test_type
        if sla.test_list.include?(test_type)
          return sla.value.to_f < test_result.to_f if sla.limit == :upper
          return sla.value.to_f > test_result.to_f if sla.limit == :lower
        end
        return true
      end
    end
  end
end
