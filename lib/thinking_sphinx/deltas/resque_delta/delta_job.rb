require 'resque-lock-timeout'

class ThinkingSphinx::Deltas::ResqueDelta::DeltaJob
  extend Resque::Plugins::LockTimeout

  @queue = :ts_delta
  @lock_timeout = 240

  # Runs Sphinx's indexer tool to process the index.
  #
  # @param [String] index the name of the Sphinx index
  #
  def self.perform(index)
    config = ThinkingSphinx::Configuration.instance
    config.controller.index index, :verbose => !config.settings['quiet_deltas']
  end

  # Try again later if lock is in use.
  def self.lock_failed(*arguments)
    Resque.enqueue(self, *arguments)
  end

  # This allows us to have a concurrency safe version of ts-delayed-delta's
  # duplicates_exist:
  #
  # http://github.com/freelancing-god/ts-delayed-delta/blob/master/lib/thinkin
  # g_sphinx/deltas/delayed_delta/job.rb#L47
  #
  # The name of this method ensures that it runs within around_perform_lock.
  #
  # We've leveraged resque-lock-timeout to ensure that only one DeltaJob is
  # running at a time. Now, this around filter essentially ensures that only
  # one DeltaJob of each index type can sit at the queue at once. If the queue
  # has more than one, lrem will clear the rest off.
  #
  def self.around_perform_lock1(*arguments)
    # Remove all other instances of this job (with the same args) from the
    # queue. Uses LREM (http://code.google.com/p/redis/wiki/LremCommand) which
    # takes the form: "LREM key count value" and if count == 0 removes all
    # instances of value from the list.
    #
    redis_job_value = Resque.encode(:class => self.to_s, :args => arguments)
    Resque.redis.lrem("queue:#{@queue}", 0, redis_job_value)

    yield
  end
end

ThinkingSphinx::Deltas::SidekiqDelta::JOB_TYPES <<
  ThinkingSphinx::Deltas::SidekiqDelta::DeltaJob
