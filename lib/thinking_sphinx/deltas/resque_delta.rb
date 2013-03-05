require 'resque'
require 'thinking_sphinx'

class ThinkingSphinx::Deltas::ResqueDelta < ThinkingSphinx::Deltas::DefaultDelta
  JOB_TYPES  = []
  JOB_PREFIX = 'ts-delta'

  # LTRIM + LPOP deletes all items from the Resque queue without loading it
  # into client memory (unlike Resque.dequeue).
  # WARNING: This will clear ALL jobs in any queue used by a ResqueDelta job.
  # If you're sharing a queue with other jobs they'll be deleted!
  def self.clear_thinking_sphinx_queues
    queues = JOB_TYPES.collect { |job| instance_variable_get(:@queue) }.uniq
    queues.each do |queue|
      Resque.redis.srem "queues", queue
      Resque.redis.del  "queue:#{queue}"
    end
  end

  # Clear both the resque queues and any other state maintained in redis
  def self.clear!
    self.clear_thinking_sphinx_queues

    FlagAsDeletedSet.clear_all!
  end

  # Use simplistic locking.  We're assuming that the user won't run more than one
  # `rake ts:si` or `rake ts:in` task at a time.
  def self.lock(index_name)
    Resque.redis.set("#{JOB_PREFIX}:index:#{index_name}:locked", 'true')
  end

  def self.unlock(index_name)
    Resque.redis.del("#{JOB_PREFIX}:index:#{index_name}:locked")
  end

  def self.locked?(index_name)
    Resque.redis.get("#{JOB_PREFIX}:index:#{index_name}:locked") == 'true'
  end

  def delete(index, instance)
    return if self.class.locked?(index.reference)

    Resque.enqueue(
      ThinkingSphinx::Deltas::ResqueDelta::FlagAsDeletedJob,
      index.name,
      index.document_id_for_key(instance.id)
    )
  end

  def index(index)
    return if self.class.locked?(index.reference)
    Resque.enqueue(
      ThinkingSphinx::Deltas::ResqueDelta::DeltaJob, index.name
    )
  end
end

require 'thinking_sphinx/deltas/resque_delta/delta_job'
require 'thinking_sphinx/deltas/resque_delta/flag_as_deleted_job'
