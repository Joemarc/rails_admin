# -*- encoding : utf-8 -*-
class RemoveHourFromRecurrences < ActiveRecord::Migration
  def change
    remove_column :recurrences, :hour, :integer
  end
end
