# -*- encoding : utf-8 -*-
class ScheduleFiller 

  def self.queue
    :background_jobs
  end

  def self.perform
    self.fill_schedule
  end

  def self.fill_schedule
    today_in_the_future = Time.zone.now.beginning_of_day + Setting.time_horizon_days.days + 1.day
    
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

  def self.fill_schedule_for_specific_day(specific_day)
    
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
  def self.fill_aliadas_availability(today_in_the_future)
    AliadaWorkingHour.active.each do |aliada_recurrence|

      if today_in_the_future.weekday == aliada_recurrence.utc_weekday(today_in_the_future)

        #Compensate for UTC 
        beginning_of_recurrence = today_in_the_future.change(hour: aliada_recurrence.utc_hour(today_in_the_future))

        zones = aliada_recurrence.aliada.zones
          
        if not Schedule.find_by(datetime: beginning_of_recurrence, aliada_id: aliada_recurrence.aliada_id)

          Schedule.create!(datetime: beginning_of_recurrence, aliada_id:  aliada_recurrence.aliada_id, zones: zones, recurrence_id: aliada_recurrence.id)

        end

      end
    end
  end

  # creates service inside aliada's schedule, based on the client's recurrence
  def self.create_service_in_clients_schedule(today_in_the_future, user_recurrence)

    # TODO: modify query with status for inactive recurrences
    base_service = user_recurrence.base_service
    unless base_service

      error = "No existen servicios para la recurrencia del usuario #{user_recurrence.user.first_name} #{user_recurrence.user.last_name}"
      Ticket.create_error(relevant_object: user_recurrence,
                          category: 'schedule_filler_error',
                          message: error)
      
      return nil

      #Rails.logger.fatal error
      #raise error
    end

    # Compensate UTC 
    beginning_of_user_recurrence = today_in_the_future.change(hour: user_recurrence.utc_hour(today_in_the_future))

    base_service_attributes = base_service.shared_attributes
    service = Service.find_by(datetime: beginning_of_user_recurrence, user_id: user_recurrence.user_id)
    if not service
      service = Service.create!(base_service_attributes.merge({datetime: beginning_of_user_recurrence }))
    end
    service.service_type = ServiceType.one_time_from_recurrent
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
        if schedules.empty? 

          error = "Aliada's future schedule was not found. Probably, the client's recurrence was not built considering the aliada's recurrence."
          Rails.logger.fatal error
          raise error

        elsif (schedules.count < user_recurrence.total_hours)
          
          error = "Aliada's schedules count #{schedules.count} didn't match number of user recurrence total hours #{user_recurrence.total_hours}"
          Rails.logger.fatal error
          raise error
          
        end
        
        service = create_service_in_clients_schedule today_in_the_future, user_recurrence

        if service
          # Assign the client to the aliada's schedule
          ScheduleInterval.new(schedules).book_schedules(aliada_id: user_recurrence.aliada_id, user_id: user_recurrence.user_id, service_id: service.id)
        end

      end
    end
  end
end
