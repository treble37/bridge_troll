class DropEventOrganizers < ActiveRecord::Migration
  Role::VOLUNTEER = 2
  Role::ORGANIZER = 3

  class EventOrganizer < ActiveRecord::Base
    belongs_to :user
    belongs_to :event
  end

  class Event < ActiveRecord::Base
    has_many :rsvps
  end

  class Rsvp < ActiveRecord::Base
    belongs_to :user
    belongs_to :event
  end

  def up
    execute('UPDATE rsvps SET role_id = ?', Role::VOLUNTEER)

    EventOrganizer.find_each do |old_organizer_rsvp|
      event = old_organizer_rsvp.event
      event.rsvps.create(user_id: old_organizer_rsvp.user.id, role_id: Role::ORGANIZER)
    end

    drop_table :event_organizers
  end

  def down
    create_table "event_organizers", :force => true do |t|
      t.integer  "user_id"
      t.integer  "event_id"
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
    end

    Rsvp.where(role_id: Role::ORGANIZER).find_each do |rsvp|
      EventOrganizer.create(
        user_id: rsvp.user_id,
        event_id: rsvp.event_id
      )
      rsvp.destroy
    end
  end
end
