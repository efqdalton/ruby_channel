class Channel
  #
  # Creates a new channel.
  #
  def initialize
    @queue   = []
    @waiting = []
    @mutex   = Mutex.new
  end

  #
  # Pushes +obj+ to the queue.
  #
  def push(obj)
    @mutex.synchronize{
      @queue.push obj
      begin
        t = @waiting.shift
        t.wakeup if t
      rescue ThreadError
        retry
      end
    }
  end

  #
  # Alias of push
  #
  alias << push

  #
  # Retrieves data from channel. If the channel is empty, the calling thread is
  # suspended until data is pushed onto channel.  If +non_block+ is true, the
  # thread isn't suspended, and an exception is raised.
  #
  def pop
    @mutex.synchronize do
      loop do
        if @queue.empty?
          @waiting.push Thread.current
          @mutex.sleep
        else
          return @queue.shift
        end
      end
    end
  end

  #
  # Retrieves data from channel like method +pop+, but if +non_block+ is true, the
  # thread isn't suspended, and an exception is raised.
  #
  def pop!
    @mutex.synchronize do
      loop do
        if @queue.empty?
          raise ThreadError, "Empty Channel"
          @waiting.push Thread.current
          @mutex.sleep
        else
          return @queue.shift
        end
      end
    end
  end

  #
  # Redirect signal to other channel
  #
  def redirect_to(channel)
    value = self.pop
    yield value if block_given?
    channel << value
  end
  alias >> redirect_to

  #
  # Returns +true+ if the channel is empty.
  #
  def empty?
    @queue.empty?
  end

  #
  # Removes all objects from the channel.
  #
  def clear
    @queue.clear
  end

  #
  # Returns the length of the channel.
  #
  def length
    @queue.length
  end

  #
  # Alias of length.
  #
  alias size length

  #
  # Returns the number of threads waiting on the queue.
  #
  def waiting_size
    @waiting.size
  end

  def subscribe(selector)
    channel = self
    @mutex.synchronize do
      loop do
        return selector.result unless selector.waiting?
        if @queue.empty?
          @waiting.push Thread.current
          @mutex.sleep
        else
          selector.mutex.synchronize do
            if selector.waiting?
              result = selector.update_result(channel, @queue.shift)
              yield result
            end
          end
          selector.release_result
          return selector.result
        end
      end
    end
  end

  #
  # Unubscribe all listeners and cleans wainting threads
  #
  # def cleanup
  #   
  # end
end