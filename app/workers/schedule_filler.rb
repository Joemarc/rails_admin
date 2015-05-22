# -*- encoding : utf-8 -*-
class ScheduleFiller 

  def self.queue
    :background_jobs
  end

  def self.perform
    Rails.logger.info "schedule_filler - step: Starting"
    self.fill_schedule
  end

  def self.fill_schedule
    now = Time.zone.now.beginning_of_day
    today_in_the_future = now + Setting.time_horizon_days.days
    
    Rails.logger.info "schedule_filler - step: fill_schedule - today_in_the_future: #{ today_in_the_future } - today_in_the_future_weekday: #{ today_in_the_future.weekday } - now: #{ now }"

    ActiveRecord::Base.transaction do
      begin
        fill_aliadas_availability today_in_the_future

        insert_clients_schedule today_in_the_future
      rescue Exception => e
        Rails.logger.fatal e 
        Raygun.track_exception(e)
        raise e
      end
    end
  end

  def self.fill_schedule_for_specific_day specific_day
    
    ActiveRecord::Base.transaction do
      begin
        fill_aliadas_availability specific_day

        insert_clients_schedule specific_day
      rescue Exception => e
        Rails.logger.fatal e 
        Raygun.track_exception(e)
        raise e
      end
    end
  end

  # aliada's recurrences, to build the whole availability
  def self.fill_aliadas_availability today_in_the_future
    Rails.logger.info "schedule_filler - step: fill_aliadas_availability"

    beginning_of_recurrence = nil

    AliadaWorkingHour.active.each do |awh|

      if today_in_the_future.weekday == awh.utc_weekday(today_in_the_future)

        Rails.logger.info "schedule_filler - step: iterating_in_awh - aliada: #{awh.aliada.full_name} - weekday: #{awh.weekday}"

        #Compensate for UTC 
        beginning_of_recurrence = today_in_the_future.change(hour: awh.utc_hour(today_in_the_future))

        if not Schedule.find_by(datetime: beginning_of_recurrence, aliada_id: awh.aliada_id)
          Schedule.create(datetime: beginning_of_recurrence,
                          aliada_id:  awh.aliada_id,
                          aliada_working_hour: awh)
        end
      end
    end

    Rails.logger.info "schedule_filler - step: last_schedule_created - beginning_of_recurrence: #{beginning_of_recurrence }"
  end

  # creates service inside aliada's schedule, based on the client's recurrence
  def self.create_service_in_clients_schedule( today_in_the_future, user_recurrence )
    # Compensate UTC 
    beginning_of_user_recurrence = today_in_the_future.change(hour: user_recurrence.utc_hour(today_in_the_future))

    recurrence_shared_attributes = user_recurrence.attributes_shared_with_service
    recurrence_shared_attributes.merge!({service_type: ServiceType.recurrent,
                                         status: 'aliada_assigned',
                                         recurrence_id: user_recurrence.id})

    service = Service.find_by(datetime: beginning_of_user_recurrence, user_id: user_recurrence.user_id)
    if not service
      service = Service.new(recurrence_shared_attributes.merge({datetime: beginning_of_user_recurrence }))
    end
    service.save!
    service 
  end

  # client's recurrences, to book inside aliada's schedule 
  def self.insert_clients_schedule( today_in_the_future )

    Recurrence.active.each do |user_recurrence| 

      if today_in_the_future.weekday == user_recurrence.utc_weekday(today_in_the_future)

        # Compensate UTC
        beginning_datetime = today_in_the_future.change(hour: user_recurrence.utc_hour(today_in_the_future))
        ending_datetime = beginning_datetime + user_recurrence.total_hours.hours

        schedules = Schedule.where("aliada_id = ? AND datetime >= ? AND datetime < ?", user_recurrence.aliada_id, beginning_datetime, ending_datetime )
        
        service = create_service_in_clients_schedule today_in_the_future, user_recurrence

        if service
          # Assign the client to the aliada's schedule
          ScheduleInterval.new(schedules).book_schedules(aliada_id: user_recurrence.aliada_id,
                                                         user_id: user_recurrence.user_id,
                                                         recurrence_id: user_recurrence.id,
                                                         service_id: service.id)
        end

      end
    end
  end
  
end
