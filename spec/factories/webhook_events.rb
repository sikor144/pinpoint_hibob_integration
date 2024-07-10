# spec/factories/webhook_events.rb

FactoryBot.define do
  factory :webhook_event do
    source { 'pinpoint' }
    event_name { 'application_hired' }
    payload { { 'data' => { 'application' => { 'id' => 1 }, 'job' => { 'id' => 1 } } } }
    status { 'created' }
    event_signature { SecureRandom.hex }
  end
end
