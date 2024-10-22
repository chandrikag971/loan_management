Rails.application.routes.draw do
  devise_for :users

  resources :loans do
    member do
      post :approve_without_adjustment
      post :approve_with_adjustment
      post :reject
      post :confirm
      post :reject_approval
      post :accept_adjustment
      post :reject_adjustment
      post :request_readjustment
      post :handle_readjustment # For admin to adjust again
      post :repay
    end
  end


  root to: 'loans#index'  # Home page that lists loans
end
