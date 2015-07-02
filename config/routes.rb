Toad::Application.routes.draw do

  resources :armor_orders, except: [:update, :edit]

  get 'search/autocomplete'
  get 'search/index', as: :search

  get 'faq' => 'static_pages#faq', as: :faq
  get 'contact_info' => 'static_pages#contact_info'
  get 'payment_info' => 'static_pages#payment_info'
  root 'static_pages#home'
  
  get 'admin' => 'layouts#admin_dashboard'
  admin_root 'layouts#admin_dashboard'

  namespace :dashboard do
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

    resources :messages do
      member do
        post :reply
        post :trash
        post :untrash
      end
    end

    resources :shipments, only: [:index]
    root 'profiles#show'
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

  devise_for :users, :controllers => { :registrations => "registrations", confirmations: 'confirmations' }
end
