Toad::Application.routes.draw do

  resources :armor_orders, except: [:update, :edit]

  get 'contacts' => 'infos#contacts_info'
  get 'payments' => 'infos#payments_info'

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

  devise_for :admin, class_name: 'User', controllers: { sessions: 'admin/sessions', confirmations: 'admin/confirmations' }

  namespace :admin do
    resources :categories
    resources :taxes
    resources :resellers, only: [:index, :update, :destroy] do
      member do
        get :get_certificate
      end
    end
    resources :products, only: [:index, :update]
    resources :mailers, only: [:index] do
      collection do
        post :services
      end
    end
    resources :importers, only: [:index, :create]
    root 'categories#index'
  end

  resources :main, only: [:index] do
    collection do
      post :search_by_sell
      post :search_by_buy
    end
  end

  root 'main#index'
end
