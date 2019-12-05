$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))

require 'simplecov'

# SimpleCov.minimum_coverage 95
SimpleCov.start

# This module is only used to check the environment is currently a testing env
module SpecHelper
end

require 'fastlane' # to import the Action super class
require 'fastlane/plugin/android_version_manage' # import the actual plugin

Fastlane.load_actions # load other actions (in case your plugin calls other actions or shared values)

def copy_project_files_fixture
  FileUtils.mkdir_p("/tmp/fastlane/tests/android-version-manage")
  source = "./spec/fixtures"
  destination = "/tmp/fastlane/tests/android-version-manage"
  FileUtils.copy_entry(source, destination)
end

def remove_project_files_fixture
  FileUtils.rm_rf("/tmp/fastlane/tests/android-version-manage")
end