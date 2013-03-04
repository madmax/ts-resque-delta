class ThinkingSphinx::Deltas::ResqueDelta::FlagAsDeletedJob
  @queue = :ts_delta

  # Runs Sphinx's indexer tool to process the index. Currently assumes Sphinx
  # is running.

  def self.perform(index, document_id)
    ThinkingSphinx::Connection.pool.take do |connection|
      connection.query(
        Riddle::Query.update(index, document_id, :sphinx_deleted => true)
      )
    end
  rescue Mysql2::Error => error
    # This isn't vital, so don't raise the error
  end
end

ThinkingSphinx::Deltas::SidekiqDelta::JOB_TYPES <<
  ThinkingSphinx::Deltas::SidekiqDelta::FlagAsDeletedJob
