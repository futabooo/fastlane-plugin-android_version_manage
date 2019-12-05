module Fastlane
  module Actions
    class AndroidCommitVersionBumpAction < Action
      def self.run(params)
        require 'pathname'
        require 'set'
        require 'shellwords'

        gradle_file_path = File.expand_path(params[:gradle_file]).shellescape
        absolute_path = File.dirname(gradle_file_path)
        repo_path = Actions.sh("git -C #{absolute_path} rev-parse --show-toplevel").strip
        repo_pathname = Pathname.new(repo_path)

        # create our list of files that we expect to have changed, they should all be relative to the project root, which should be equal to the git workdir root
        expected_changed_files = []
        expected_changed_files << absolute_path

        # get the list of files that have actually changed in our git workdir
        git_dirty_files = Actions.sh("git -C #{repo_path} diff --name-only HEAD").split("\n") + Actions.sh("git -C #{repo_path} ls-files --other --exclude-standard").split("\n")
        if git_dirty_files.empty?
          UI.user_error!("No file changes picked up. Make sure you run the `increment_version_code` action first.")
        end

        # check if the files changed are the ones we expected to change (these should be only the files that have version info in them)
        changed_files_as_expected = Set.new(git_dirty_files.map(&:downcase)).subset?(Set.new(expected_changed_files.map(&:downcase)))

        unless changed_files_as_expected
          unless params[:force]
            error = [
              "Found unexpected uncommited changes in the working directory. Expected these files to have ",
              "changed: \n#{expected_changed_files.join("\n")}.\nBut found these actual changes: ",
              "#{git_dirty_files.join("\n")}.\nMake sure you have cleaned up the build artifacts and ",
              "are only left with the changed version files at this stage in your lane, and don't touch the ",
              "working directory while your lane is running. You can also use the :force option to bypass this ",
              "check, and always commit a version bump regardless of the state of the working directory."
            ].join("\n")
            UI.user_error!(error)
          end
        end

        # get the absolute paths to the files
        git_add_paths = expected_changed_files.map do |path|
          updated = path
          updated.replace(updated.sub(repo_pathname.to_s, "./")) # .gsub(repo_pathname, ".")
          puts(" -- updated = #{updated}".yellow)
          File.expand_path(File.join(repo_pathname, updated))
        end

        # then create a commit with a message
        command_add = build_git_command_add(repo_path, git_add_paths.map(&:shellescape).join(' '))
        Actions.sh(command_add)

        begin
          command_commit = build_git_command(params, repo_path)
          Actions.sh(command_commit)
          UI.success("Committed \"#{params[:message]}\" 💾.")
        rescue => ex
          UI.error(ex)
          UI.important("Didn't commit any changes.")
        end
      end

      def self.description
        "This action is like a commit_version_bump action for Android"
      end

      def self.authors
        ["futabooo"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        # Optional:
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :gradle_file,
                                       env_name: "FL_ANDROID_COMMIT_VERSION_BUMP_GRADLE_FILE",
                                       description: "(optional) Specify the path to your app build.gradle if it isn't in the default location",
                                       optional: true,
                                       type: String,
                                       default_value: "app/build.gradle"),
          FastlaneCore::ConfigItem.new(key: :message,
                                       env_name: "FL_ANDROID_COMMIT_VERSION_BUMP_COMMIT_MESSAGE",
                                       description: "(optional) The commit message when committing the version bump",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :force,
                                       env_name: "FL_ANDROID_COMMIT_VERSION_BUMP_FORCE_COMMIT",
                                       description: "(optional) Forces the commit, even if other files than the ones containing the version number have been modified",
                                       optional: true,
                                       default_value: false,
                                       is_string: false),
          FastlaneCore::ConfigItem.new(key: :no_verify,
                                       env_name: "FL_ANDROID_COMMIT_VERSION_BUMP_GIT_PUSH_USE_NO_VERIFY",
                                       description: "Whether or not to use --no-verify",
                                       type: Boolean,
                                       default_value: false)
        ]
      end

      def self.is_supported?(platform)
        platform == :android
      end

      class << self
        def build_git_command_add(repo_path, paths)
          command = ['git',
                     '-C',
                     "'#{repo_path}'",
                     'add',
                     "'#{paths}'"]

          return command.join(' ')
        end

        def build_git_command_commit(params, repo_path)
          version_code = Actions.lane_context[SharedValues::ANDROID_NEW_VERSION_CODE]

          params[:message] ||= (version_code ? "Version Bump to #{version_code}" : "Version Bump")

          command = [
            'git',
            '-C',
            "'#{repo_path}'",
            'commit',
            '-m',
            "'#{params[:message]}'"
          ]

          command << '--no-verify' if params[:no_verify]

          return command.join(' ')
        end
      end
    end
  end
end
