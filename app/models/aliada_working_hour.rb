class AliadaWorkingHour < Recurrence
  include AliadaSupport::DatetimeSupport

  default_scope { where(owner: 'aliada') }

  def self.update_from_admin aliada_id, activated_recurrences, disabled_recurrences, new_recurrences

    activated_recurrences.each do |recurrence|
      awh = AliadaWorkingHour.find_by(aliada_id: aliada_id, hour: recurrence[:hour], weekday: recurrence[:weekday])
      awh.activate!
      # mark future schedules of that weekday and hour as available
      awh.schedules.in_the_future.busy.map(&:enable)
    end

    disabled_recurrences.each do |recurrence|
      awh = AliadaWorkingHour.find_by(aliada_id: aliada_id, hour: recurrence[:hour], weekday: recurrence[:weekday])
      awh.deactivate!
      # mark future schedules of that weekday and hour as busy 
      awh.schedules.in_the_future.busy_candidate.map(&:get_busy) 
    end

    new_recurrences.each do |recurrence|
      aliada = Aliada.find(aliada_id)

      aliada.zones.each do |zone|
        awh = AliadaWorkingHour.find_or_create_by(aliada_id: aliada_id, weekday: recurrence[:weekday], hour: recurrence[:hour], periodicity: 7, owner: 'aliada', total_hours: 1, user_id: nil)
        # fill 30 days of schedules
        awh.create_schedules_until_horizon        
      end

    end

  end

  def create_schedules_until_horizon

    Chronic.time_class= ActiveSupport::TimeZone[self.timezone]
    starting_datetime = Chronic.parse("next #{self.weekday}").change(hour: self.hour)

    recurrence_days = wdays_until_horizon(self.wday, starting_from: starting_datetime)

    recurrence_days.times do |i|
      schedule = Schedule.find_or_initialize_by(aliada_id: self.aliada_id, datetime: starting_datetime)
      if schedule.new_record?
        schedule.zones = self.aliada.zones
        schedule.recurrence_id = self.id
        schedule.save!
      else
        if schedule.recurrence_id and schedule.recurrence_id != self.id
          raise "Schedule #{schedule.id} with current recurrence ID #{schedule.recurrence_id} trying to be updated to ID #{self.id}"
        else
          schedule.update_attribute(:recurrence_id, self.id)
        end
      end
      starting_datetime += self.periodicity.day
    end

  end

  rails_admin do
    visible false
    label_plural 'Horas de trabajo disponibles'
    parent Aliada
    navigation_icon 'icon-time'
  end
end

