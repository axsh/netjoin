# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "netjoin"
  spec.version       = '0.1-beta'
  spec.date			 = '2015-08-01'
  spec.authors       = ["Axsh Co. LTD."]
  spec.email         = ["dev@axsh.net"]
  spec.summary       = %q{Set up VPN networks}
  spec.description   = spec.summary
  spec.homepage      = "http://axsh.jp/"
  spec.license       = "LGPLv3"

  spec.files         = ['lib/netjoin.rb']
  spec.executables   = ['bin/netjoin']
  spec.require_paths = ["lib"]

  s.required_ruby_version = '>= 1.9.3'
end
