Toad::Application.routes.draw do

  Blogo::Routes.mount_to(self, at: '/blog')

  match "/404", :to => "errors#not_found", :via => :all
  match "/500", :to => "errors#internal_server_error", :via => :all

  resources :stripe_orders do
    collection do
      post :purchase
    end
  end

  resources :green_orders

  resources :amg_orders

  resources :emb_orders

  resources :fly_buy_orders, except: [:edit, :new, :create, :show, :index, :destroy, :update] do
    collection do
      post :set_inspection_date, to: 'fly_buy_orders#set_inspection_date', as: 'set_inspection_date'
      get :set_inspection_date
    end
    post :confirm_inspection_date_by_seller
    get :complete_inspection
    get :release_payment
    get :release_payment_to_additional_sellers_not_possible
    get :release_payment_to_additional_sellers
    post :place_order
    post :confirm_order_placed
    get :resend_wire_instruction
    get :cancel_transaction
  end

  get 'print/invoice.:id', to: 'print#invoice', as: 'print/invoice'

  get 'search/autocomplete'
  get 'search/index', as: :search

  get 'fly' => 'static_pages#escrow_faq', as: :escrow_faq
  get 'trust' => 'static_pages#toadlane_trust', as: :toadlane_trust
  get 'faq' => 'static_pages#faq', as: :faq
  get 'faque' => 'static_pages#faque', as: :faque
  get 'terms_of_service' => 'static_pages#terms_of_service'
  get 'pay' => 'static_pages#pay'
  get 'account_deactivated' => 'static_pages#account_deactivated'
  root 'static_pages#home'

  namespace :dashboard do
    resources :notifications, only: [:index] do
      collection do
        delete :delete_cascade
      end
    end

    resource :profile, only: [:update, :show] do
      collection do
        put :update_i_buy_and_sell
      end
    end

    resources :accounts do
      collection do
        post :create_green_profile
        get :send_confirmation_email
        get :check_valid_phone_number
        get :check_valid_state
        post :create_amg_profile
        post :create_emb_profile
        post :create_fly_buy_profile
        post :answer_kba_question
      end
    end

    resource :finances, only: [:create, :show]

    resources :folders

    resources :products, except: :show do
      collection do
        delete :delete_cascade
        post :active_cascade
        post :inactive_cascade
        post :import
        get 'template'
        get '/:id/viewers', to: 'products#viewers', as: 'viewers'
      end
    end

    resources :requests
    resources :offers

    resources :groups do
      collection do
        get :accept_deal
        get :reject_deal
        post :assign_role
        post :change_visibility_of_member
        get :validate_group_name, as: :validate_group_name
        get :resend_invitation
        get :remove_group_member
      end
    end

    resources :orders, only: [:index, :show] do
      collection do
        delete :delete_cascade
        get :cancel_order
        post :request_new_inspection_date, to: 'orders#request_new_inspection_date', as: 'request_new_inspection_date'
        post :approve_new_inspection_date, to: 'orders#approve_new_inspection_date', as: 'approve_new_inspection_date'
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

  resources :messages, only: [:create] do
    collection do
      post :group_member_message
      post ':user_id/individual_user' => :individual_user, as: :individual_user
      get :group_admin_message
      post :send_group_admin_message
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
      get :for_sale
      get :requested
      get :deals
      get 'subregion_options'
      get '/get_certificate/:certificate_id', to: 'products#get_certificate', as: 'get_certificate'
    end
    match '/checkout', to: 'products#checkout', :via => [:get, :post]
  end

  devise_for :users, :controllers => { :registrations => "registrations", confirmations: 'confirmations', :omniauth_callbacks => "omniauth_callbacks", :sessions => "users/sessions", :invitations => "users/invitations" }

  namespace :admin do
    namespace :fly_buy do
      resources :account_verifications, only: [:index]  do
        collection do
          get :mark_user_unverify
          get :mark_user_verify
        end
      end
      resources :group_verifications, only: [:index] do
        collection do
          get :mark_group_verify
          get :mark_group_unverify
        end
      end
    end

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

  authenticate :user, lambda { |user| user.has_role?(:admin) } do
    mount Searchjoy::Engine, at: 'admin/searchjoy'
  end

  mount Commontator::Engine => '/commontator'

  match '/postmark/inbound', to: 'messages#inbound', :via => [:get, :post]

  match '/synapsepay/26143155/callback', to: 'dashboard/accounts#callback', via: [:get, :post]
end
