Swidjit::Application.routes.draw do
  devise_for :users, :controllers => { :registrations => "registrations",
      :omniauth_callbacks => "omniauth_callbacks" }

  resources :want_its, :have_its, :thoughts, :links, :events, :except => :index do
    member do
      get :toggle_active
      get :duplicate
      post :add_visibility_rule
      delete :remove_visibility_rule
      resources :recommendations, :only => :create
    end
  end

  resource :feeds, :only => [] do
    member do
      %w( all have_its want_its events thoughts links ).each do |act|
        get "#{act.to_sym}(/:tag_name)", :action => act.to_sym, :as => "#{act}"
      end
      get :drafts
      get 'recommendations(/:type)', :action => :recommendations, :as => 'recommendations'
      get 'familiar_users(/:type)', :action => :familiar_users, :as => 'familiar_users'
    end
  end

  resources :tags, :only => [] do
    collection do
      get :autocomplete_search
    end
  end

  resources :item_preset_tags, :only => [:index, :new, :create, :destroy]

  resources :communities, :only => [:new,:create,:show,:index] do
    member do
      post :join
      delete :leave
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
    end
  end

  resources :delegates, :only => [:create,:destroy]

  resources :bookmarks, :only => [:create,:destroy,:index]

  # This needs to stay at the bottom such that a user can't override a preset URL
  match '/:display_name', :controller => :users, :action => :show, :as => :profile

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'home#index'

end
