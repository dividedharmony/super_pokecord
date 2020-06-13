# frozen_string_literal: true

class Duration
  ONE_MINUTE_IN_SECONDS = 60
  ONE_HOUR_IN_SECONDS = ONE_MINUTE_IN_SECONDS * 60

  class << self
    def hours_in_seconds(number_of_hours)
      number_of_hours * ONE_HOUR_IN_SECONDS
    end

    def minutes_in_seconds(number_of_minutes)
      number_of_minutes * ONE_MINUTE_IN_SECONDS
    end

    def countdown_string(future_time)
      diff_in_seconds = (future_time - Time.now).to_i
      num_hours = diff_in_seconds / ONE_HOUR_IN_SECONDS
      num_minutes = (diff_in_seconds % ONE_HOUR_IN_SECONDS) / ONE_MINUTE_IN_SECONDS
      num_seconds = (diff_in_seconds % ONE_HOUR_IN_SECONDS) % ONE_MINUTE_IN_SECONDS

      "#{num_hours}h #{num_minutes}m #{num_seconds}s"
    end
  end
end
