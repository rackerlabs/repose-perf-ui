module SnapshotComparerModule
  module Helpers
    class RouteHelper
      def return_404_json(application)
         halt 404, {'Content-Type' => 'application/json'},  {'fail' => 'invalid application specified'}.to_json
      end

      def return_404(application)
        halt 404, "no application found: #{application}"
      end

      def get_application(application, is_json)
        app = Apps::Bootstrap.application_list.find {|a| a[:id] == application}
        return_404(application) unless (app && !is_json)
        return_404_json(application) unless (app && is_json)
        app
      end

      def verify_sub_app(application, name, settings, is_json)
        sub_app = nil
        app = verify_application(application)
        if app
          new_app = app[:klass].new(settings.deployment)
          sub_app = new_app.config['application']['sub_apps'].find do |sa|
            sa['id'] == name
          end
        else
          halt 404
        end
        sub_app
      end

      def verify_sub_app_with_test(application, name, test_type, settings)
        sub_app = nil
        app = verify_application(application)
        if app and Apps::Bootstrap.test_list.keys.include?(test)
          new_app = app[:klass].new(settings.deployment)
          sub_app = new_app.config['application']['sub_apps'].find do |sa|
            sa['id'] == name
          end
        end
        sub_app
      end
    end
  end
end
