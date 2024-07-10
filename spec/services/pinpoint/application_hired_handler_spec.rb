# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pinpoint::ApplicationHiredHandler, type: :handler do
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
          'email' => 'john.doe@example.com',
          'attachments' => [
            { 'context' => 'pdf_cv', 'url' => 'http://example.com/john_doe_cv.pdf' }
          ]
        }
      }
    }
  end

  let(:employee) { { 'id' => 123 } }
  let(:application_fetcher) { instance_double('Apis::Pinpoint::Applications::Fetch', call: application) }
  let(:employee_creator) { instance_double('Apis::HiBob::People::Create', call: employee) }
  let(:document_uploader) { instance_double('Apis::HiBob::People::AddSharedDocument', call: true) }
  let(:comment_creator) { instance_double('Apis::Pinpoint::Applications::AddComment', call: true) }

  subject { described_class.new(event) }

  before do
    allow(Apis::Pinpoint::Applications::Fetch).to receive(:new).and_return(application_fetcher)
    allow(Apis::HiBob::People::Create).to receive(:new).and_return(employee_creator)
    allow(Apis::HiBob::People::AddSharedDocument).to receive(:new).and_return(document_uploader)
    allow(Apis::Pinpoint::Applications::AddComment).to receive(:new).and_return(comment_creator)
  end

  describe '#call' do
    it 'fetches the application data' do
      expect(application_fetcher).to receive(:call).with(id: 1, options: { extra_fields: %w[attachments] })
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

    it 'uploads the CV as a public document to HiBob' do
      expect(document_uploader).to receive(:call).with(
        person_id: 123,
        document_name: 'CV',
        document_url: 'http://example.com/john_doe_cv.pdf'
      )
      subject.call
    end

    it 'adds a comment to the application' do
      expect(comment_creator).to receive(:call).with(
        id: 1,
        comment: 'Record created with ID: 123'
      )
      subject.call
    end
  end
end
