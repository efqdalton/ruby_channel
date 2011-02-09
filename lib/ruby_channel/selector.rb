class Selector
  attr_reader :waiting, :result
  alias waiting? waiting

  def initialize
    @threads       = []
    @waiting       = true
    @mutex         = Mutex.new
    @return_thread = nil
  end

  def listen(channel, &block)
    selector = self
    Thread.new{ channel.subscribe(selector, block) }
  end

  def timeout(value, &block)
    timeout_channel = Channel.new
    Thread.new{ sleep value; timeout_channel << :timeout }
    listen timeout_channel, &block
  end

  def select
    @mutex.synchronize do
      if waiting?
        @return_thread = Thread.current
        @mutex.sleep
      end
    end
    @threads.each{ |thread| thread.wakeup }
    @threads.clear
    return @result
  end

  def update_result(channel, value)
    @waiting = false
    @result  = value
    @return_thread.run if @return_thread
  end
end