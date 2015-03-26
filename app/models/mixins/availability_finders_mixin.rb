module Mixins
  # Commonly used methods in our availability finding classes
  module AvailabilityFindersMixin
    # State trackers
    def initialize_trackers
      # An object to track our availability
      @aliadas_availability = Availability.new

      # save time consecutive schedules 
      # until the desired size is reached
      @continuous_schedules = []
       
      # A list to track errors and help debug
      @report = []
    end

    def load_schedules
      # Pull the schedules from db
      @schedules = Schedule.for_booking(@zone, @available_after)
      if @aliada_id.present? && !@aliada_id.zero? # We use 0 to represent any aliada
        @schedules = @schedules.where(aliada_id: @aliada_id)
      end
      # Eval the query to avoid multiple queries later on thanks to lazy evaluation
      @schedules.to_a
    end

    def continuous_schedules_same_aliada?(last_continuous, current_interval)
      # If we are starting a continuity
      return true if last_continuous.blank?

      last_continuous.aliada_id == current_interval.aliada_id && 
      last_continuous.datetime + 1.hour == current_interval.datetime
    end

    def skip_aliada!
      @aliadas_to_skip.push(@current_aliada_id)
    end

    def skip_aliada?
      @aliadas_to_skip.include?(@current_aliada_id)
    end

    def continuous_schedule_intervals?(previous_interval, current_interval)
      (current_interval - previous_interval) == @recurrency_seconds
    end

    def sort_schedules!
      @schedules.sort_by! { |schedule| [ schedule.aliada_id, schedule.datetime ] }
    end

    def enough_continuous_schedules?
      @continuous_schedules.size >= @requested_service_hours
    end

    def clear_not_enough_availabilities
      if @aliadas_availability.present? && @is_recurrent
        @aliadas_availability.delete_if do |aliada_id, wday_hour_intervals|
          wday_hour_intervals.delete_if do |wday_hour, intervals_hash|

            next if intervals_hash.values.first.nil?

            minimum_availabilities = wdays_until_horizon( intervals_hash.values.first.wday, starting_from: @available_after )

            value = intervals_hash.size < minimum_availabilities
            @report.push({message: 'Cleared a too few availability', objects: [minimum_availabilities, intervals_hash] }) if value

            value
          end

        wday_hour_intervals.blank?
        end
      end
    end

    def free_schedules_count_after_current(current_index)
      schedules_count_after_current(current_index).select { |s| s.nil? || s.available? }.count
    end

    def available_schedules_count_after_current(current_index)
      schedules_count_after_current(current_index).select { |s| s.try(:available?) }.count
    end

    def schedules_count_after_current(current_index)
      next_schedule = schedule_at_index(current_index + 1)
      next_next_schedule = schedule_at_index(current_index + 2)

      [next_schedule, next_next_schedule]
    end

    def schedule_at_index(i)
      @schedules.fetch(i, nil)
    end

    def schedules_between(start, ending)
      @schedules[start..ending]
    end

    def last_continuous_schedule_index
      i = @current_index
      current_schedule = @current_schedule
      next_schedule = schedule_at_index(i + 1)

      while current_schedule.present? &&
            next_schedule.present? && 
            current_schedule.available? &&
            next_schedule.available? &&
            free_schedules_count_after_current(i) == 2 && 
            continuous_schedules_same_aliada?(current_schedule, next_schedule)
        i += 1
        current_schedule = schedule_at_index(i)
        next_schedule = schedule_at_index(i+1)
      end

      i
    end

    # Do we have a pair of continues schedules?
    # belonging to the same aliada_id?
    def is_continuous?
      last_continuous = @continuous_schedules.last

      continuous_schedules_same_aliada?(last_continuous, @current_schedule)
    end

    def add_next_schedules_availability
      # At this point there's a @continuous_schedules of @minimum_service_hours size
      # and we will build all the available intervals in front of it, shrinking and growing the
      # availability as needed while cycling on the schedules
      #

      # The index of the last continuous schedule 
      availability_limit = last_continuous_schedule_index
      # Our starting point
      first_schedule_index = @continuous_schedules.first.index
      @report.push({message: "At #{@current_schedule.datetime} there are #{free_schedules_count_after_current(@current_index)} available schedules in front"})

      i = 0
      while true
        # For this iteration the index of the last possible
        last_schedule_index = first_schedule_index + @maximum_service_hours
        minimum_schedule_index = first_schedule_index + @requested_service_hours - 1

        # Shrink to fit the available space
        if last_schedule_index > availability_limit
          to_shrink = availability_limit - last_schedule_index
          last_schedule_index += to_shrink
        else
          to_shrink = 0
          last_schedule_index -= 1
        end

        if minimum_schedule_index <= last_schedule_index
          padding = last_schedule_index - minimum_schedule_index
        end

        schedules_for_availabilty = schedules_between(first_schedule_index, last_schedule_index)

        add_availability(schedules_for_availabilty)

        # When our interval can't be smaller, quit
        break if schedules_for_availabilty.size == @requested_service_hours

        first_schedule_index += 1
        i += 1
      end

    end

    def add_availability(schedules)
      new_interval = ScheduleInterval.new(schedules, 
                                          aliada_id: @current_aliada_id,
                                          elements_for_key: @requested_service_hours)
      interval_key = wday_hour(schedules)

      @aliadas_availability.add(interval_key , new_interval, @current_aliada_id)
    end

    def broken_continous_intervals?
      current_interval = ScheduleInterval.new(@continuous_schedules, aliada_id: @current_aliada_id)

      interval_key = wday_hour(current_interval)
      previous_interval = @aliadas_availability.previous_interval(@current_aliada_id, interval_key, current_interval)

      # The first time there is no previous
      return false if previous_interval.blank?

      value = !continuous_schedule_intervals?(previous_interval, current_interval)
      if value
        @report.push({message: 'Found 1 broken recurrent continuity', objects: [previous_interval, current_interval] })
      end

      value
    end

    def wday_hour(continuous_schedules)
      schedule = continuous_schedules.first
      "#{schedule.datetime.wday}-#{schedule.datetime.hour}"
    end

    def is_available?
      @current_schedule.available?
    end

    def enable_service_schedules
      if @service.present?
        # We will consider the passed service schedules as available (without saving the status change)
        # just for this run, we'll restore their state later
        #

        services_ids = @service.related_services_ids

        @previous_service_schedules = []
        @schedules.each do |schedule|
          next if !services_ids.include? schedule.service_id

          schedule.original_status = schedule.status.dup
          schedule.status = 'available' if schedule.status == 'booked' || schedule.status == 'padding'
          @previous_service_schedules.push(schedule)
        end

        @aliadas_availability.previous_service_schedules = @previous_service_schedules
      end
    end

    def restore_service_schedules_original_state
      return unless @previous_service_schedules.present?

      @previous_service_schedules.each do |schedule|
        schedule.status = schedule.original_status if schedule.status == 'available' # we dont want to override our padding status setting
      end
    end
  end
end
