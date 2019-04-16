Rails.application.routes.draw do
  devise_for :users

  root controller: :rooms, action: :index

  resources :room_messages
  resources :rooms do
        collection do
      get :buzzer
    end
  end
end
