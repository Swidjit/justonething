Swidjit::Application.routes.draw do
  devise_for :users, :controllers => { :registrations => "registrations",
      :omniauth_callbacks => "omniauth_callbacks" }

  scope :module => 'admin' do
    resources :item_preset_tags, :only => [:index, :new, :create, :destroy]
    resources :items, :only => [] do
      collection do
        get :flagged
      end
      put :disable
    end
  end

  resources :want_its, :have_its, :thoughts, :links, :events, :collections, :except => :index do
    member do
      put :flag
      get :toggle_active
      get :duplicate
      post :add_visibility_rule
      delete :remove_visibility_rule
      resources :recommendations, :only => :create
      resources :comments, :only => :create
    end
  end

  resources :collections, :only => [] do
    member do
      post :add_item
    end
  end

  resources :items, :only => [] do
    resources :offers, :only => [:create, :index]
    resources :users, :only => [] do
      resources :offers, :only => :index
    end
  end

  resource :feeds, :only => [] do
    member do
      get 'geo/:tag_name', :action => :geo, :as => 'geo'
      get :drafts
      get 'recommendations(/:type)', :action => :recommendations, :as => 'recommendations'
      get 'familiar_users(/:type)', :action => :familiar_users, :as => 'familiar_users'
      get :search, :action => :search
      get ':type(/:tag_name)', :action => :index, :as => 'main', :defaults => { :type => :all }
    end
  end

  resources :tags, :only => [] do
    collection do
      get :autocomplete_search
      get :autocomplete_search_geo
    end
  end

  resources :communities, :only => [:new,:create,:show,:index] do
    member do
      post :join
      delete :leave
      resources :community_invitations, :only => :create
    end
  end

  resources :lists, :only => [:show,:create,:destroy] do
    member do
      post :add_user
      post :delete_user
    end
  end

  resources :users, :only => [:edit, :update] do
    member do
      get :visibility_options
      get :references
      get :suggestions
    end
    resources :offers, :only => :index
    resources :vouches, :only => :create
    resources :notifications, :only => :index
  end

  resources :calendar, :only => [:index] do
    collection do
      get :week, :path => "week/:week_no", :controller => :calendar, :action => :index
      get :date, :path => "date/:month/:day/:year", :controller => :calendar, :action => :index
    end
  end

  resources :delegates, :only => [:create,:destroy]

  resources :bookmarks, :only => [:create,:destroy,:index]

  match 'contact' => 'contact#new', :as => 'contact', :via => :get
  match 'contact' => 'contact#create', :as => 'contact', :via => :post

  resources :rsvps, :only => [:create,:destroy,:index]

  post '/images/generate' => 'images#generate'

  resources :offers, :only => [:destroy] do
    resources :offer_messages, :only => [:create]
  end

  # This needs to stay at the bottom such that a user can't override a preset URL
  match '/:display_name', :controller => :users, :action => :show, :as => :profile

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'feeds#index'

end
