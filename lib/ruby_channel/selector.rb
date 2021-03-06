module RubyChannel
  class Selector
    attr_reader :waiting, :result, :mutex
    alias waiting? waiting

    def initialize
      @threads       = []
      @waiting       = true
      @mutex         = Mutex.new
      @return_thread = nil
    end

    def listen(channel, &block)
      selector = self
      @threads << Thread.new do
        Thread.current[:name]  = "Listener" if RubyChannel::CHANNEL_DEBUG
        channel.subscribe(selector, &block)
      end
    end

    def timeout(value, &block)
      timeout_channel = Channel.new
      Thread.new do
        Thread.current[:name]  = "Timeout Listener" if RubyChannel::CHANNEL_DEBUG
        sleep value
        timeout_channel << :timeout
      end
      listen timeout_channel, &block
    end

    def default(&block)
      default_channel = Channel.new
      Thread.new do
        Thread.current[:name]  = "Default Listener" if RubyChannel::CHANNEL_DEBUG
        default_channel << :default
      end
      listen default_channel, &block
    end

    def select
      Thread.current[:name] = "select" if RubyChannel::CHANNEL_DEBUG
      @mutex.synchronize do
        if waiting?
          @return_thread = Thread.current
          Thread.list.each{|t| puts "#{t.inspect}: #{t[:name]}"} if RubyChannel::CHANNEL_DEBUG
          @mutex.sleep
        end
      end
      @threads.each{ |thread| thread.wakeup if thread.alive? }
      @threads.clear
      return @result
    end

    def update_result(channel, value)
      @waiting = false
      @result  = value
    end

    def release_result
      @return_thread.run if @return_thread
    end
  end
end