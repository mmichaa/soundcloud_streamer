# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'soundcloud_streamer/version'

Gem::Specification.new do |spec|
  spec.name          = "soundcloud_streamer"
  spec.version       = SoundcloudStreamer::VERSION
  spec.authors       = ["Michael Nowak"]
  spec.email         = ["thexsystem@gmail.com"]
  spec.summary       = %q{streams and saves whole playlist and single tracks as mp3 from soundcloud via api.}
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/mmichaa/#{spec.name}"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 1.9.3'

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"

  spec.add_development_dependency "pry", "~> 0.10"

  spec.add_runtime_dependency "ruby-mp3info", "~> 0.8"
  spec.add_runtime_dependency "soundcloud", "~> 0.3"
  spec.add_runtime_dependency "typhoeus", "~> 0.6"
  spec.add_runtime_dependency "thor", "~> 0.19"
end
