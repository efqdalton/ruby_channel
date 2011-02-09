# -*- encoding: utf-8 -*-
require File.expand_path("../lib/ruby_channel/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "ruby_channel"
  s.version     = RubyChannel::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Dalton Pinto']
  s.email       = ['dalthon@aluno.ita.br']
  s.homepage    = "http://rubygems.org/gems/ruby_channel"
  s.summary     = "A way to use channels in Ruby, inspired by Google's Go"
  s.description = "A way to use channels in Ruby, inspired by Google's Go"

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "ruby_channel"

  s.add_development_dependency "bundler", ">= 1.0.0"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
