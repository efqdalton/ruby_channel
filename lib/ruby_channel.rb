require 'monitor'
require 'thread'

load 'ruby_channel/version.rb'
gem_path = File.dirname __FILE__
autoload :Channel,  File.join(gem_path, "ruby_channel/channel.rb")
autoload :Selector, File.join(gem_path, "ruby_channel/selector.rb")