# frozen_string_literal: true

require_relative "lib/dear_dirty_rails_controller/version"

Gem::Specification.new do |spec|
  spec.name = "dear-dirty-rails-controller"
  spec.version = DearDirtyRailsController::VERSION
  spec.authors = ["youtaman"]
  spec.email = ["akikiuv+youtaman@gmail.com"]

  spec.summary = "dear-dirty-rails-controller is a gem for drawing controllers in a clean and beautiful way."
  spec.description = "dear-dirty-rails-controller is a gem for drawing controllers in a clean and beautiful way."
  spec.homepage = "https://github.com/youtaman/dear-dirty-rails-controller"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/youtaman/dear-dirty-rails-controller"
  spec.metadata["changelog_uri"] = "https://github.com/youtaman/dear-dirty-rails-controller/blob/master/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = IO.popen(%w[du -a lib], chdir: __dir__, err: IO::NULL) { |ls| ls.readlines.to_a }
                 .map { _1.split("\t").last.split("\n").first }
                 .filter { _1.end_with? ".rb" }.to_a
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport"
  spec.add_dependency "actionpack"
end
