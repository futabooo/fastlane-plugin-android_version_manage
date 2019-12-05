module Fastlane
  module Actions
    module SharedValues
      ANDROID_NEW_VERSION_CODE = :ANDROID_NEW_VERSION_CODE
    end

    class AndroidSetVersionCodeAction < Action
      def self.run(params)
        gradle_file_path = Helper::AndroidVersionManageHelper.get_gradle_file_path(params[:gradle_file])
        new_version_code = Helper::AndroidVersionManageHelper.get_new_version_code(gradle_file_path, params[:version_code])

        UI.message(gradle_file_path)

        saved = Helper::AndroidVersionManageHelper.save_key_to_gradle_file(gradle_file_path, "versionCode", new_version_code)

        if saved == -1
          UI.user_error!("Unable to set the Version Code #{gradle_file_path}.")
        end

        UI.success("☝️ Android Version Code has been set to: #{new_version_code}")

        # Store the Version Code in the shared hash
        Actions.lane_context[SharedValues::ANDROID_NEW_VERSION_CODE] = new_version_code
      end

      def self.description
        "Set the Version Code of your Android project"
      end

      def self.authors
        ["futabooo"]
      end

      def self.output
        [
          ['ANDROID_NEW_VERSION_CODE', 'The new Version Code of Android project']
        ]
      end

      def self.return_value
        "The new Version Code of your Android project"
      end

      def self.details
        [
          "This action will set the new Version Code on your Android project.",
          "Without specifying new Version Code, current one will be incremented"
        ].join(' ')
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :gradle_file,
                                       env_name: "FL_ANDROID_VERSION_MANAGE_GRADLE_FILE",
                                       description: "(optional) Specify the path to your app build.gradle if it isn't in the default location",
                                       optional: true,
                                       type: String,
                                       default_value: "app/build.gradle.kts",
                                       verify_block: proc do |value|
                                         UI.user_error!("Could not find #{value} file") unless File.exist?(value) || Helper.test?
                                       end),
          FastlaneCore::ConfigItem.new(key: :version_code,
                                       env_name: "FL_ANDROID_VERSION_MANAGE_VERSION_CODE",
                                       description: "(optional) Set specific Version Code",
                                       optional: true,
                                       type: Integer,
                                       default_value: nil)
        ]
      end

      def self.is_supported?(platform)
        platform == :android
      end
    end
  end
end
