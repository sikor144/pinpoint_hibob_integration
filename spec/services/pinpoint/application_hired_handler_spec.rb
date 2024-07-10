require 'rails_helper'

require_relative '../../../app/services/pinpoint/fetch_application'
require_relative '../../../app/services/hi_bob/create_employee'
require_relative '../../../app/services/hi_bob/add_cv_to_employee'
require_relative '../../../app/services/pinpoint/add_comment_to_application'
require_relative '../../../app/errors/pinpoint/error'
require_relative '../../../app/errors/hi_bob/error'

module Pinpoint
  RSpec.describe ApplicationHiredHandler, type: :handler do
    let(:event_payload) { { 'data' => { 'application' => { 'id' => application_id } } } }
    let(:application_id) { '12345' }
    let(:application_data) do
      {
        'data' => {
          'attributes' => {
            'first_name' => 'John',
            'last_name' => 'Doe',
            'email' => 'john.doe@example.com',
            'attachments' => attachments
          }
        }
      }
    end
    let(:attachments) { [{ 'context' => 'pdf_cv', 'url' => 'http://example.com/cv.pdf' }] }
    let(:employee_data) { { 'id' => '67890' } }
    let(:event) { instance_double('Event', payload: event_payload) }

    before do
      allow_any_instance_of(Pinpoint::FetchApplication).to receive(:call).and_return(application_data)
      allow_any_instance_of(HiBob::CreateEmployee).to receive(:call).and_return(employee_data)
      allow_any_instance_of(HiBob::AddCvToEmployee).to receive(:call)
      allow_any_instance_of(Pinpoint::AddCommentToApplication).to receive(:call)
    end

    subject { described_class.new(event) }

    describe '#call' do
      context 'when the process is successful' do
        it 'fetches the application' do
          expect_any_instance_of(Pinpoint::FetchApplication).to receive(:call).with(application_id)
          subject.call
        end

        it 'creates an employee' do
          expect_any_instance_of(HiBob::CreateEmployee).to receive(:call).with(application_data)
          subject.call
        end

        it 'adds the CV to the employee' do
          expect_any_instance_of(HiBob::AddCvToEmployee).to receive(:call).with(employee_data['id'], 'CV', 'http://example.com/cv.pdf')
          subject.call
        end

        it 'adds a comment to the application' do
          expect_any_instance_of(Pinpoint::AddCommentToApplication).to receive(:call).with(application_id,
                                                                                           employee_data['id'])
          subject.call
        end
      end

      context 'when there is a custom error' do
        before do
          allow_any_instance_of(Pinpoint::FetchApplication).to receive(:call).and_raise(Pinpoint::Error,
                                                                                        'Custom error message')
        end

        it 'handles the custom error' do
          expect(Rails.logger).to receive(:error).with(/Custom Error in ApplicationHiredHandler: Custom error message/)
          expect do
            subject.call
          end.to raise_error(Pinpoint::WebhookEventError,
                             /Failed to process application hired event: Custom error message/)
        end
      end

      context 'when there is a standard error' do
        before do
          allow_any_instance_of(Pinpoint::FetchApplication).to receive(:call).and_raise(StandardError,
                                                                                        'Standard error message')
        end

        it 'handles the standard error' do
          expect(Rails.logger).to receive(:error).with(/Error in ApplicationHiredHandler: Standard error message/)
          expect do
            subject.call
          end.to raise_error(Pinpoint::WebhookEventError,
                             /Failed to process application hired event: Standard error message/)
        end
      end
    end
  end
end
