require 'spec_helper'

describe Fastlane::Actions::AndroidCommitVersionBumpAction do
  let(:action) { Fastlane::Actions::AndroidCommitVersionBumpAction }

  describe 'build_git_command_commit' do
    it 'creates a git commit with the provided message' do
      command = action.build_git_command_commit({ message: "my commit message" }, "/path/to/repo/root")

      expect(command).to eq("git -C '/path/to/repo/root' commit -m 'my commit message'")
    end

    it 'creates a default commit message if no message or build number is provided' do
      command = action.build_git_command_commit({ no_verify: false }, "/path/to/repo/root")

      expect(command).to eq("git -C '/path/to/repo/root' commit -m 'Version Bump'")
    end

    it 'creates a commit message containing the build number if no message is provided' do
      Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::ANDROID_NEW_VERSION_CODE] = "123"
      command = action.build_git_command_commit({ no_verify: false }, "/path/to/repo/root")

      expect(command).to eq("git -C '/path/to/repo/root' commit -m 'Version Bump to 123'")
    end

    it 'appends the --no-verify if required' do
      command = action.build_git_command_commit({ message: "my commit message", no_verify: true }, "/path/to/repo/root")

      expect(command).to eq("git -C '/path/to/repo/root' commit -m 'my commit message' --no-verify")
    end
  end
end
