# spec/controllers/webhooks_controller_spec.rb

require 'rails_helper'

RSpec.describe WebhooksController, type: :controller do
  describe 'POST #create' do
    let(:params) do
      {
        event: 'application_hired',
        triggeredAt: 1_614_687_278,
        data: {
          application: { id: 1 },
          job: { id: 1 }
        }
      }
    end

    context 'when the request is valid' do
      before do
        allow_any_instance_of(Pinpoint::WebhookVerificationService).to receive(:verified?).and_return(true)
        allow(Pinpoint::WebhookVerificationService).to receive(:new).and_return(double(verified?: true))
      end

      it 'returns http success' do
        post :create, params:, as: :json
        expect(response).to have_http_status(:ok)
      end

      it 'calls the webhook event handler' do
        handler_instance = instance_double(Pinpoint::WebhookEventHandler)
        allow(Pinpoint::WebhookEventHandler).to receive(:new).and_return(handler_instance)
        expect(handler_instance).to receive(:handle_event)

        post :create, params:, as: :json
      end
    end

    context 'when the request is unauthorized' do
      before do
        allow_any_instance_of(Pinpoint::WebhookVerificationService).to receive(:verified?).and_return(false)
        allow(Pinpoint::WebhookVerificationService).to receive(:new).and_return(double(verified?: false))
      end

      it 'returns http unauthorized' do
        allow_any_instance_of(Pinpoint::WebhookVerificationService).to receive(:verified?).and_return(false)
        post :create, params:, as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when an ActiveRecord::RecordInvalid error occurs' do
      before do
        allow_any_instance_of(Pinpoint::WebhookVerificationService).to receive(:verified?).and_return(true)
        allow(Pinpoint::WebhookVerificationService).to receive(:new).and_return(double(verified?: true))
      end

      it 'returns http unprocessable entity' do
        handler_instance = instance_double(Pinpoint::WebhookEventHandler)
        allow(Pinpoint::WebhookEventHandler).to receive(:new).and_return(handler_instance)
        allow(handler_instance).to receive(:handle_event).and_raise(ActiveRecord::RecordInvalid.new(WebhookEvent.new))

        post :create, params:, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when an unexpected error occurs' do
      before do
        allow_any_instance_of(Pinpoint::WebhookVerificationService).to receive(:verified?).and_return(true)
        allow(Pinpoint::WebhookVerificationService).to receive(:new).and_return(double(verified?: true))
      end

      it 'returns http internal server error' do
        handler_instance = instance_double(Pinpoint::WebhookEventHandler)
        allow(Pinpoint::WebhookEventHandler).to receive(:new).and_return(handler_instance)
        allow(handler_instance).to receive(:handle_event).and_raise(StandardError.new('Unexpected error'))

        post :create, params:, as: :json
        expect(response).to have_http_status(:internal_server_error)
      end
    end
  end
end
