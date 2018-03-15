# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bub_bot/version'

Gem::Specification.new do |spec|
  spec.name          = "bub_bot"
  spec.version       = BubBot::VERSION
  spec.authors       = ["Kevin Kuchta"]
  spec.email         = ["kevin@kevinkuchta.com"]

  spec.summary       = %q{A little server reservation and deploy bot for heroku and aptible}
  spec.homepage      = "https://github.com/kkuchta/bub_bot"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rack", "~> 1.0"
  spec.add_dependency "thin", "~> 1.0"
  spec.add_dependency "git"
  spec.add_dependency "activesupport"
  spec.add_dependency "faraday"
  spec.add_dependency 'actionview'
  spec.add_dependency "redis"
  spec.add_dependency 'slack-ruby-client'

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec-mocks", "~> 3.5"
  spec.add_development_dependency "pry-byebug"
end
