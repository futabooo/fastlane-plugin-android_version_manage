describe Fastlane::Actions::AndroidVersionManageAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The android_version_manage plugin is working!")

      Fastlane::Actions::AndroidVersionManageAction.run(nil)
    end
  end
end
