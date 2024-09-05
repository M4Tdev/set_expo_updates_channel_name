lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/plugin/update_channel_metadata/version'

Gem::Specification.new do |spec|
  spec.name          = 'fastlane-plugin-update_channel_metadata'
  spec.version       = Fastlane::UpdateChannelMetadata::VERSION
  spec.author        = 'Mateusz'
  spec.email         = 'mateo.lesiuk@gmail.com'

  spec.summary       = 'Updates Channel Metadata'
  # spec.homepage      = "https://github.com/<GITHUB_USERNAME>/fastlane-plugin-update_channel_metadata"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*"] + %w(README.md LICENSE)
  spec.require_paths = ['lib']
  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.required_ruby_version = '>= 2.6'

  # Don't add a dependency to fastlane or fastlane_re
  # since this would cause a circular dependency

  # spec.add_dependency 'your-dependency', '~> 1.0.0'
end
