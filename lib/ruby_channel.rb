require 'monitor'
require 'thread'

puts Dir.pwd
puts $0
puts __FILE__

require 'ruby_channel/channel'
require 'ruby_channel/selector'
require 'ruby_channel/version'