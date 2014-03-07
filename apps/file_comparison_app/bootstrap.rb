  require 'fileutils'
  require 'yaml'
  require 'logging'
  require 'redis'
  require 'open-uri'
  require File.expand_path("apps/bootstrap.rb", Dir.pwd)

module SnapshotComparer
  module Apps
    class FileComparisonAppBootstrap < Bootstrap


      def initialize(environment = :production, redis_info = nil, logger = nil)
        if environment == :production
          @config = YAML.load_file(File.expand_path("config/apps/file_comparison_app.yaml", Dir.pwd))
        elsif environment == :test
          @config = YAML.load_file(File.expand_path("config/apps/test_file_comparison_app.yaml", Dir.pwd))
        elsif environment == :development
          @config = YAML.load_file(File.expand_path("config/apps/dev_file_comparison_app.yaml", Dir.pwd))
        end

        super(redis_info, logger)
      end

      def retrieve_adhoc_view(name = nil)
        if name && name == 'custom'
          "file_comparison_app_custom_adhoc".to_sym
        else
          "file_comparison_app_adhoc".to_sym
        end
      end

      def retrieve_adhoc_view_locals(application, name, test)
        locals = {
          :application => application,
          :sub_app_id => name.to_sym,
          :test_type => test,
          :title => @config['application']['name'],
          :running_test => retrieve_running_test_info(application, name, test)
        }
        # get versions
        locals[:versions] = ['3.0','2.13.1', '2.13.0', '2.12']
        locals[:test_types] = Apps::Bootstrap.test_list
        locals
      end
    end
  end
end
