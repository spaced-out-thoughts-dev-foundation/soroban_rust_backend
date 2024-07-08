#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'

# Path to your gemspec file and manifest file
gemspec_path = 'dtr_to_rust.gemspec'
manifest_path = 'bean_stock_manifest.yaml'

# Extract version from gemspec
gemspec = File.read(gemspec_path)
version_match = gemspec.match(/\.version\s*=\s*["']([^"']+)["']/)
version = version_match[1] if version_match

# Read the manifest file
manifest = YAML.load_file(manifest_path)

# Update the version field
manifest['version'] = version

# Write back to the manifest file
File.write(manifest_path, manifest.to_yaml)

puts "Updated manifest version to #{version}"
