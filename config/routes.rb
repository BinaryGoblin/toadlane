Toad::Application.routes.draw do

  resources :armor_orders, except: [:update, :edit]


  get 'search' => 'search#index', as: :search

  namespace :dashboards, path: 'dashboard' do
    resource :profile, only: [:update, :show]

    resources :payments

    resources :products, except: :show do
      collection do
        delete :delete_cascade
        post :active_cascade
        post :inactive_cascade
      end
    end

    resources :orders, only: [:index] do
      collection do
        delete :delete_cascade
      end
    end

    resources :shipments, only: [:index]

    root 'profiles#show'
  end

  resources :search do
    collection do
      get :autocomplete
    end
  end

  resources :categories do
    member do
      get :sub_categories
    end
  end

  resources :products, only: [:index, :show] do
    collection do
      get 'all' => 'products#products'
      get :offers
      get :deals
    end
  end

  resources :messages, only: [:create]
  resources :requests, only: [:create]

  devise_for :users, :controllers => { :registrations => "registrations", confirmations: 'confirmations' }

  get 'faq' => 'static_pages#faq', as: :faq
  get 'contact_info' => 'static_pages#contact_info'
  get 'payment_info' => 'static_pages#payment_info'
  root 'static_pages#home'
end
