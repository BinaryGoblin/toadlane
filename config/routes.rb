Toad::Application.routes.draw do

  resources :armor_orders, except: [:update, :edit]

  get 'search/autocomplete'
  get 'search/index', as: :search

  get 'faq' => 'static_pages#faq', as: :faq
  get 'contact_info' => 'static_pages#contact_info'
  get 'payment_info' => 'static_pages#payment_info'
  root 'static_pages#home'
  get 'terms_of_service' => 'static_pages#terms_of_service'
  
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

    resources :terms_of_services, only: [:index] do
      collection do
        put 'update_terms'
      end
    end
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
end
