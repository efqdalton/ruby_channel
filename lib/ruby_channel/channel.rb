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
  def pop(non_block=false)
    @mutex.synchronize{
      loop do
        if @queue.empty?
          raise ThreadError, "queue empty" if non_block
          @waiting.push Thread.current
          @mutex.sleep
        else
          return @queue.shift
        end
      end
    }
  end

  #
  # Alias of pop
  #
  alias >> pop

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
    @mutex.synchronize do
      loop do
        if @queue.empty?
          @waiting.push Thread.current
          @mutex.sleep
        else
          selector.mutex.synchronize do
            selector.update_result(channel, @queue.shift) if selector.waiting?
          end
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