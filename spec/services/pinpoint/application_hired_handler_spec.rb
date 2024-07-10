# spec/services/pinpoint/application_hired_handler_spec.rb

require 'rails_helper'

RSpec.describe Pinpoint::ApplicationHiredHandler, type: :service do
  let(:event) do
    double('WebhookEvent', payload: {
             'data' => {
               'application' => { 'id' => 1 }
             }
           })
  end

  let(:application) do
    {
      'data' => {
        'attributes' => {
          'first_name' => 'John',
          'last_name' => 'Doe',
          'email' => 'john.doe@example.com'
        }
      }
    }
  end

  let(:application_fetcher) { instance_double('Apis::Pinpoint::Applications::Fetch', call: application) }
  let(:employee_creator) { instance_double('Apis::HiBob::People::Create', call: true) }

  subject { described_class.new(event) }

  before do
    allow(subject).to receive(:application_fetcher).and_return(application_fetcher)
    allow(subject).to receive(:employee_creator).and_return(employee_creator)
  end

  describe '#call' do
    it 'fetches the application data' do
      expect(application_fetcher).to receive(:call).with(id: 1)
      subject.call
    end

    it 'creates an employee with the fetched application data' do
      expected_start_date = 2.weeks.from_now

      expect(employee_creator).to receive(:call).with(
        first_name: 'John',
        surname: 'Doe',
        email: 'john.doe@example.com',
        site: 'New York (Demo)',
        start_date: be_within(1.second).of(expected_start_date)
      )
      subject.call
    end
  end
end
