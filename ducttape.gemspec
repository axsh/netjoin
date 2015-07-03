# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "ducttape"
  spec.version       = '0.1'
  spec.authors       = ["Kenny Debrauwer"]
  spec.email         = ["kenny@axsh.net"]
  spec.summary       = %q{Set up VPN network between VDC's}
  spec.description   = %q{Set up VPN network between VDC's}
  spec.homepage      = "http://axsh.jp/"
  spec.license       = "MIT"

  spec.files         = ['lib/ducttape.rb']
  spec.executables   = ['bin/ducttape']
  spec.test_files    = ['tests/test_ducttape.rb']
  spec.require_paths = ["lib"]
end
