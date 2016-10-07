Toad::Application.routes.draw do

  Blogo::Routes.mount_to(self, at: '/blog')

  match "/404", :to => "errors#not_found", :via => :all
  match "/500", :to => "errors#internal_server_error", :via => :all

  match "/callbacks", :to => "promise_orders#callbacks", :via => :all

  resources :armor_orders, except: [:edit, :new] do
    collection do
      post :set_inspection_date, to: 'armor_orders#set_inspection_date', as: 'set_inspection_date'
      get :set_inspection_date
      post :armor_webhooks
    end
    post :confirm_inspection_date_by_seller
    get :complete_inspection
  end

  resources :stripe_orders do
    collection do
      post :purchase
    end
  end

  resources :green_orders

  resources :amg_orders

  resources :emb_orders

  resources :promise_orders, except: [:edit, :new, :create, :show, :index, :destroy, :update] do
    collection do
      post :set_inspection_date, to: 'promise_orders#set_inspection_date', as: 'set_inspection_date'
      get :set_inspection_date
    end
    post :confirm_inspection_date_by_seller
    get :complete_inspection
    post :place_order
    get :refund
  end

  resources :fly_buy_orders, except: [:edit, :new, :create, :show, :index, :destroy, :update] do
    collection do
      post :set_inspection_date, to: 'fly_buy_orders#set_inspection_date', as: 'set_inspection_date'
      get :set_inspection_date
    end
    post :confirm_inspection_date_by_seller
    get :complete_inspection
    get :release_payment
    post :place_order
    post :confirm_order_placed
    get :resend_wire_instruction
    get :cancel_transaction
  end

  get 'print/invoice.:id', to: 'print#invoice', as: 'print/invoice'

  get 'search/autocomplete'
  get 'search/index', as: :search

  get 'escrow' => 'static_pages#escrow_faq', as: :escrow_faq
  get 'faq' => 'static_pages#faq', as: :faq
  get 'terms_of_service' => 'static_pages#terms_of_service'
  get 'account_deactivated' => 'static_pages#account_deactivated'
  root 'static_pages#home'

  namespace :dashboard do
    resources :notifications, only: [:index] do
      collection do
        delete :delete_cascade
      end
    end

    resource :profile, only: [:update, :show]

    resources :accounts do
      collection do
        get :set_armor_profile
        post :create_green_profile
        post :create_armor_profile
        get :send_confirmation_email
        get :check_valid_phone_number
        get :check_valid_state
        post :create_amg_profile
        post :create_emb_profile
        post :create_fly_buy_profile
        post :update_fly_buy_profile
        # get :callback
        # post :callback
      end
    end

    resource :finances, only: [:create, :show]

    resources :products, except: :show do
      collection do
        delete :delete_cascade
        post :active_cascade
        post :inactive_cascade
        get '/:id/viewers', to: 'products#viewers', as: 'viewers'
      end
    end

    resources :orders, only: [:index, :show] do
      collection do
        delete :delete_cascade
        get :cancel_order
      end
    end

    resources :refund_requests, only: [:index] do
      collection do
        delete :cancel_refund
        get :accept_refund
        get :reject_refund
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

    resources :forms, path: "verify"

    resources :terms_of_services, only: [:index] do
      collection do
        put 'update_terms'
      end
    end

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
      get 'subregion_options'
      get '/get_certificate/:certificate_id', to: 'products#get_certificate', as: 'get_certificate'
    end
    match '/checkout', to: 'products#checkout', :via => [:get, :post]
  end

  devise_for :users, :controllers => { :registrations => "registrations", confirmations: 'confirmations', :omniauth_callbacks => "omniauth_callbacks", :sessions => "users/sessions" }

  namespace :admin do
    resources :categories

    resources :fees

    resources :products, except: :show do
      collection do
        delete :delete_cascade
        post :active_cascade
        post :inactive_cascade
      end
    end

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

  authenticate :user, lambda{|user| user.has_role?(:admin) } do
    mount Searchjoy::Engine, at: "admin/searchjoy"
  end

  mount Commontator::Engine => '/commontator'

  match '/postmark/inbound', to: 'messages#inbound', :via => [:get, :post]

end
