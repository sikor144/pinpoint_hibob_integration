class CreateWebhookEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :webhook_events do |t|
      t.string :source
      t.string :event_name
      t.json :payload, default: {}
      t.string :status, default: 'created'

      t.timestamps
    end

    add_index :webhook_events, :source
    add_index :webhook_events, :event_name
    add_index :webhook_events, :status
  end
end
