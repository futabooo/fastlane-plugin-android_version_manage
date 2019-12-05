require 'spec_helper'

describe Fastlane::Helper::AndroidVersionManageHelper do
  describe "Android Version Manage Helper" do
    it "should return path to build.gradle" do
      result = Fastlane::Helper::AndroidVersionManageHelper.get_gradle_file(nil)

      expect(result).to eq(Fastlane::Helper::AndroidVersionManageHelper::GRADLE_FILE_TEST)
    end

    it "should return absolute path to build.gradle" do
      android_project_path = "tmp/fastlane/tests/android-version-manage"
      result = Fastlane::Helper::AndroidVersionManageHelper.get_gradle_file_path(android_project_path)

      expect(result).to eq("/tmp/fastlane/tests/android-version-manage/app/build.gradle.kts")
    end
  end
end
