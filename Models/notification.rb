require 'mail'

module SnapshotComparer
  module Models
    class Notification
      attr_reader :notification_type

    def self.notifications
      {
        :mail => MailNotification
      }
    end

      def initialize(notification_type)
        @notification_type = notification_type
      end
 
      def get_users
        @notification_type.users
      end

      def send_notification
        @notification_type.send_notification
      end
    end

    class MailNotification
      attr_accessor :users
      attr_reader :from
      attr_reader :subject
      attr_reader :message

      def initialize(user_list, subject, message)
        @users = user_list
        @from = 'performance@openrepose.org'
        @subject = subject
        @message = message
      end

      def send_notification
        mail = Mail.new
        mail[:from] = @from
        mail[:to] = @users
        mail[:subject] = @subject
        mail[:body] = @message
        mail.deliver!
      end
    end
  end
end 
