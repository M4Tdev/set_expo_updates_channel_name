# require 'fastlane/action'
# require_relative '../helper/update_channel_metadata_helper'

# module Fastlane
#   module Actions
#     class UpdateChannelMetadataAction < Action
#       def self.run(params)
#         UI.message("The update_channel_metadata plugin is working!")
#       end

#       def self.description
#         "Updates Channel Metadata"
#       end

#       def self.authors
#         ["Mateusz"]
#       end

#       def self.return_value
#         # If your method provides a return value, you can describe here what it does
#       end

#       def self.details
#         # Optional:
#         "Updates Channel metadata for Expo Updates"
#       end

#       def self.available_options
#         [
#           # FastlaneCore::ConfigItem.new(key: :your_option,
#           #                         env_name: "UPDATE_CHANNEL_METADATA_YOUR_OPTION",
#           #                      description: "A description of your option",
#           #                         optional: false,
#           #                             type: String)
#         ]
#       end

#       def self.is_supported?(platform)
#         # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
#         # See: https://docs.fastlane.tools/advanced/#control-configuration-by-lane-and-by-platform
#         #
#         # [:ios, :mac, :android].include?(platform)
#         true
#       end
#     end
#   end
# end



require 'fastlane/action'
require 'nokogiri'
require 'plist'
require 'json'

module Fastlane
  module Actions
    class UpdateChannelMetadataAction < Action
      def self.run(params)
        channel_name = params[:channel_name]

        # Update Android Manifest
        manifest_path = params[:manifest_path]
        if manifest_path && File.exist?(manifest_path)
          update_android_manifest(manifest_path, channel_name)
        else
          UI.important("AndroidManifest.xml path not provided or file does not exist, skipping Android update.")
        end

        # Update iOS Expo.plist
        plist_path = params[:plist_path]
        if plist_path && File.exist?(plist_path)
          update_expo_plist(plist_path, channel_name)
        else
          UI.important("Expo.plist path not provided or file does not exist, skipping iOS update.")
        end

        # Update app.json
        app_json_path = params[:app_json_path]
        if app_json_path && File.exist?(app_json_path)
          update_app_json(app_json_path, channel_name)
        else
          UI.important("app.json path not provided or file does not exist, skipping app.json update.")
        end
      end

      def self.update_android_manifest(manifest_path, new_channel)
        # Read and parse the XML file
        manifest_content = File.read(manifest_path)
        xml_doc = Nokogiri::XML(manifest_content)

        # Find the <meta-data> tag with the desired name
        metadata_tag = xml_doc.at_xpath("//meta-data[@android:name='expo.modules.updates.UPDATES_CONFIGURATION_REQUEST_HEADERS_KEY']")

        # Ensure the tag exists
        if metadata_tag
          # Replace the android:value attribute
          metadata_tag['android:value'] = "{\"expo-channel-name\":\"#{new_channel}\"}"

          # Write the changes back to the file
          File.write(manifest_path, xml_doc.to_xml)

          UI.message("Updated expo-channel-name to '#{new_channel}' in #{manifest_path}")
        else
          UI.user_error!("Could not find the meta-data tag with android:name='expo.modules.updates.UPDATES_CONFIGURATION_REQUEST_HEADERS_KEY' in #{manifest_path}")
        end
      end

      def self.update_expo_plist(plist_path, new_channel)
        # Read the plist file
        plist_content = Plist.parse_xml(plist_path)

        # Ensure the plist is parsed correctly
        unless plist_content
          UI.user_error!("Could not parse the Expo.plist file at #{plist_path}")
        end

        # Update the value for 'expo-channel-name' key
        if plist_content['expo-channel-name']
          plist_content['expo-channel-name'] = new_channel

          # Write the changes back to the file
          File.open(plist_path, 'w') { |f| f.write(plist_content.to_plist) }

          UI.message("Updated expo-channel-name to '#{new_channel}' in #{plist_path}")
        else
          UI.user_error!("Could not find the key 'expo-channel-name' in the Expo.plist file at #{plist_path}")
        end
      end

      def self.update_app_json(app_json_path, new_channel)
        # Read the app.json file
        app_json_content = JSON.parse(File.read(app_json_path))

        # Navigate to the requestHeaders and update expo-channel-name
        if app_json_content['expo'] && app_json_content['expo']['updates'] && app_json_content['expo']['updates']['requestHeaders']
          app_json_content['expo']['updates']['requestHeaders']['expo-channel-name'] = new_channel

          # Write the changes back to the file
          File.open(app_json_path, 'w') { |f| f.write(JSON.pretty_generate(app_json_content)) }

          UI.message("Updated expo-channel-name to '#{new_channel}' in #{app_json_path}")
        else
          UI.user_error!("Could not find the 'requestHeaders' key in the app.json file at #{app_json_path}")
        end
      end

      def self.description
        "Updates the expo-channel-name in AndroidManifest.xml, Expo.plist, and app.json"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :manifest_path,
                                       description: "Path to the AndroidManifest.xml file",
                                       optional: true,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :plist_path,
                                       description: "Path to the Expo.plist file",
                                       optional: true,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :app_json_path,
                                       description: "Path to the app.json file",
                                       optional: true,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :channel_name,
                                       description: "New channel name to set in the metadata",
                                       optional: false,
                                       type: String)
        ]
      end

      def self.is_supported?(platform)
        platform == :android || platform == :ios
      end
    end
  end
end
