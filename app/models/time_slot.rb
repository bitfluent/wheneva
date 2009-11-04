class TimeSlot
  attr_reader :num_of_days, :first_slot, :last_slot

  def initialize(num_of_days = 7, first_slot = 9, last_slot = 17)
    @num_of_days = num_of_days
    @first_slot  = first_slot
    @last_slot   = last_slot
  end

  def populate(dates)
    dates.each do |d|
      self.insert(d)
    end
    slots
  end

  def insert(date)
    slots[day_index(date)][hour_index(date)] = true
  end

  def earliest_slot
    @earliest_slot ||= Time.zone.today + first_slot.hours
  end

  def day_index(date)
    relative_date = date - earliest_slot
    (relative_date / 1.day).floor
  end

  def hour_index(date)
    relative_date = date - earliest_slot
    ((relative_date - day_index(date).days) / 1.hour).floor
  end

  def slots
    @slots ||= begin
      slots = []
      num_of_days.times do |day|
        slots[day] = Array.new(num_of_slots)
      end
      slots
    end
  end

  def num_of_slots
    @num_of_slots ||= self.last_slot - self.first_slot
  end
end
