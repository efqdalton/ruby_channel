require 'monitor'
require 'thread'

require 'ruby_channel/channel.rb'
require 'ruby_channel/selector.rb'
require 'ruby_channel/version.rb'

module Kernel
  def go(*args)
    Thread.new do
      begin
        yield(*args)
      rescue Exception => e
        p e
        p e.backtrace
      end
    end
  end

  def select_channel
    s = Selector.new
    yield s
    s.select
  end
end
