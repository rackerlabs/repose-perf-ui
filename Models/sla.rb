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
        if sla.test_list.include?(test_type)
          return "Last test failed SLA!  SLA \"#{sla.name}\" maximum threshold is set to #{sla.value}#{sla.value_type}; however last test returned a result of #{test_result}#{sla.value_type}\n\n" if sla.value.to_f < test_result.to_f && sla.limit == :upper
          return "Last test failed SLA!  SLA \"#{sla.name}\" minimum threshold is set to #{sla.value}#{sla.value_type}; however last test returned a result of #{test_result}#{sla.value_type}\n\n" if sla.value.to_f > test_result.to_f && sla.limit == :lower
        end
      end

    end
  end
end
