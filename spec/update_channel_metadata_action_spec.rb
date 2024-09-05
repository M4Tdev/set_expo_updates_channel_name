describe Fastlane::Actions::UpdateChannelMetadataAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The update_channel_metadata plugin is working!")

      Fastlane::Actions::UpdateChannelMetadataAction.run(nil)
    end
  end
end
