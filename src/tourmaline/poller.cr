module Tourmaline
  # The `Poller` class is responsible for polling Telegram's API for updates,
  # and then passing them to the `Dispatcher` for processing.
  class Poller
    Log = ::Log.for(self)

    getter offset : Int64

    def initialize(client : Tourmaline::Client)
      @client = client
      @offset = 0_i64
      @polling = false
    end

    # Starts polling Telegram's API for updates.
    def start
      @client.delete_webhook
      Log.info { "Polling for updates..." }
      @polling = true
      while @polling
        poll_and_dispatch
      end
    end

    def stop
      @polling = false
    end

    def poll_and_dispatch
      updates = get_updates
      updates.each do |update|
        @client.dispatcher.process(update)
        @offset = Int64.new(update.update_id + 1)
      end
    rescue ex : DB::PoolRetryAttemptsExceeded
      raise ex
    rescue ex : Error::RetryAfter
      Log.info { "Flood control exceeded while polling. Retrying in #{ex.seconds} seconds." }
      sleep(ex.seconds)
    rescue ex
      Log.error(exception: ex) { "Error during polling" }
    end

    def get_updates
      @client.get_updates(offset: offset, timeout: 30)
    end
  end
end
