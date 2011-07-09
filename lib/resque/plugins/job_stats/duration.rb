module Resque
  module Plugins
    module JobStats
      module Duration

        # Resets all job durations
        def reset_job_durations
          Resque.redis.del(jobs_duration_key)
        end

        # Returns the number of jobs failed
        def job_durations
          Resque.redis.lrange(jobs_duration_key,0,job_durations_to_track).map(&:to_f)
        end

        # Returns the key used for tracking job durations
        def jobs_duration_key
          @jobs_failed_key ||= "stats:jobs:#{self.name}:duration"
        end

        # Increments the failed count when job is complete
        def around_perform_job_stats_duration(*payload)
          start = Time.now
          yield
          duration = Time.now - start

          Resque.redis.multi do
            Resque.redis.lpush(jobs_duration_key, duration)
            Resque.redis.ltrim(jobs_duration_key, 0, job_durations_to_track)
          end
        end

        def job_durations_to_track
          100
        end

      end
    end
  end
end