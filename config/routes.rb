Toad::Application.routes.draw do

  match "/404", :to => "errors#not_found", :via => :all
  match "/500", :to => "errors#internal_server_error", :via => :all

  resources :armor_orders, except: [:update, :edit, :new]
  
  resources :stripe_orders do
    collection do
      post :purchase
    end
  end
  
  get 'print/invoice.:id', to: 'print#invoice', as: 'print/invoice'

  get 'search/autocomplete'
  get 'search/index', as: :search

  get 'faq' => 'static_pages#faq', as: :faq
  get 'terms_of_service' => 'static_pages#terms_of_service'
  get 'account_deactivated' => 'static_pages#account_deactivated'
  root 'static_pages#home'
  
  namespace :dashboard do
    resource :profile, only: [:update, :show]

    resources :accounts
    
    resource :finances, only: [:create, :show]

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

    resources :messages do
      member do
        post :reply
        post :trash
        post :untrash
      end
    end

    resources :shipments, only: [:index]

    resources :forms
    
    root 'profiles#show'
  end
  
  resources :messages, only: [:create]

  resources :categories do
    member do
      get :sub_categories
    end
  end

  resources :products, only: [:index, :show] do
    collection do
      get 'all' => 'products#products'
      get :for_sale
      get :requested
      get :deals
    end
  end

  devise_for :users, :controllers => { :registrations => "registrations", confirmations: 'confirmations', :omniauth_callbacks => "omniauth_callbacks" }
  
  devise_for :admin, class_name: 'User', controllers: { sessions: 'admin/sessions', confirmations: 'admin/confirmations' }

  namespace :admin do
    resources :categories
    resources :fees
    resources :products, only: [:index, :update]
    resources :orders, only: [:index, :update] do
      collection do
        delete :delete_cascade
      end
    end
    resources :mailers, only: [:index] do
      collection do
        post :services
      end
    end
    resources :importers, only: [:index, :create]
    root 'categories#index'

    namespace :users do
      resources :verifications, only: [:index, :update, :destroy] do
        member do
          get :get_certificate
        end
      end
     
      resources :managements, only: [:index] do
        collection do
          put :activate
          put :deactivate
          put :promote
          put :demote
        end
      end
      resources :communications, only: [:index]
    end
  end  
end
