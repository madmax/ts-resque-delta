require 'thinking_sphinx/deltas/Resque_delta'

namespace :ts do
  desc 'Lock all delta indices (Resque will not run indexer or place new jobs on the :ts_delta queue).'
  task :lock_deltas do
    ThinkingSphinx::Deltas::ResqueDelta::CoreIndex.new.lock_deltas
  end

  desc 'Unlock all delta indices.'
  task :unlock_deltas do
    ThinkingSphinx::Deltas::ResqueDelta::CoreIndex.new.unlock_deltas
  end

  desc 'Like `rake thinking_sphinx:index`, but locks one index at a time.'
  task :smart_index => :app_env do
    ret = ThinkingSphinx::Deltas::ResqueDelta::CoreIndex.new.smart_index

    abort("Indexing failed.") if ret != true
  end
end

namespace :ts do
  desc 'Like `rake thinking_sphinx:index`, but locks one index at a time.'
  task :si => 'thinking_sphinx:smart_index'
end

unless Rake::Task.task_defined?('ts:index')
  require 'thinking_sphinx/tasks'
end
