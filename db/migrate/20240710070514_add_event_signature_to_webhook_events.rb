class AddEventSignatureToWebhookEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :webhook_events, :event_signature, :string
    add_index :webhook_events, :event_signature, unique: true
  end
end
