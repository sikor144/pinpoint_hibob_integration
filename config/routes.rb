Rails.application.routes.draw do
  post 'webhooks', to: 'webhooks#create'

  get 'up' => 'rails/health#show', as: :rails_health_check
end
