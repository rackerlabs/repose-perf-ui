require './Models/notification.rb'
require 'test/unit'
require 'yaml'

class MailNotificationTest < Test::Unit::TestCase

  def setup
    @config = YAML.load_file(File.expand_path("config/apps/test_atom_hopper.yaml", Dir.pwd))
    @notification_recipients = @config['application']['notification']['mail']
  end

  def test_initialize_with_data
    notification = SnapshotComparer::Models::MailNotification.new(
       @notification_recipients,'This is a test','OMG! This is generated from the codez! http://performance.repose.rax.io/repose/results/atom_hopper/load_test/id/1d33db6c-08ff-4fd9-bc24-f216064b7940+1b5eab55-703d-4125-a068-5bc386f79394')

    notification.send_notification
  end
end
