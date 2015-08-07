Rails.application.routes.draw do
  mount JasmineRails::Engine => '/specs' if defined?(JasmineRails)

  def ssl_options
    if CatarseSettings[:secure_host]
      {protocol: 'https', host: CatarseSettings[:secure_host]}
    else
      {}
    end
  end

  devise_for(
    :users,
    {
      path: '',
      path_names:   { sign_in: :login, sign_out: :logout, sign_up: :sign_up },
      controllers:  { omniauth_callbacks: :omniauth_callbacks, passwords: :passwords }
    }
  )

  devise_scope :user do
    post '/sign_up', {to: 'devise/registrations#create', as: :sign_up}
  end

  get '/obrigado' => "static#thank_you"

  filter :locale, exclude: /\/auth\//

  mount CatarsePaypalExpress::Engine => "/", as: :catarse_paypal_express
  mount CatarseMoip::Engine => "/", as: :catarse_moip
  mount CatarseCredits::Engine => "/", as: :catarse_credits
  mount CatarsePagarme::Engine => "/", as: :catarse_pagarme
  mount CatarseJuntosGiftCards::Engine => "/", :as => :catarse_juntos_gift_cards
#  mount CatarseWepay::Engine => "/", as: :catarse_wepay

  resources :site_partners, only: :index, path: :parceiros
  resources :presses, only: :index
  get '/post_preview' => 'post_preview#show', as: :post_preview
  resources :categories, only: [] do
    member do
      get :subscribe, to: 'categories/subscriptions#create'
      get :unsubscribe, to: 'categories/subscriptions#destroy'
    end
  end
  resources :auto_complete_projects, only: [:index]
  resources :projects, only: [:index, :create, :update, :new, :show] do
    resources :posts, controller: 'projects/posts', only: [ :index, :create, :destroy ]
    resources :rewards, only: [ :index, :create, :update, :destroy, :new, :edit ] do
      member do
        post 'sort'
      end
    end
    resources :contributions, {controller: 'projects/contributions'}.merge(ssl_options) do
      member do
        put 'credits_checkout'
      end
    end
    collection do
      get 'video'
    end
    member do
      get :reminder, to: 'projects/reminders#create'
      delete :reminder, to: 'projects/reminders#destroy'
      get :metrics, to: 'projects/metrics#index'
      put 'pay'
      get 'embed'
      get 'video_embed'
      get 'about_mobile'
      get 'embed_panel'
      get 'send_to_analysis'
    end
  end
  resources :users do
    resources :projects, controller: 'users/projects', only: [ :index ]
    resources :credit_cards, controller: 'users/credit_cards', only: [ :destroy ]
    member do
      get :unsubscribe_notifications
      get :credits
      get :reactivate
    end
    resources :contributions, controller: 'users/contributions', only: [:index] do
      member do
        get :request_refund
      end
    end

    resources :unsubscribes, only: [:create]
    member do
      get :approve
      get 'projects'
      put 'unsubscribe_update'
      put 'update_email'
      put 'update_password'
    end
  end

  resources :donators, only: %i(new create)

  get "/termos-de-uso" => 'high_voltage/pages#show', id: 'terms_of_use', as: 'terms_of_use'
  get "/politica-de-privacidade" => 'high_voltage/pages#show', id: 'privacy_policy', as: 'privacy_policy'
  get "/como-funciona" => 'high_voltage/pages#show', id: 'start', as: :start

  get "/quem-somos" => 'who_we_are#show', id: 'who_we_are', as: 'who_we_are'
  get "/ongs" => 'ongs#index', id: 'ongs', as: :ongs
  get "/contato" => 'contact#index', id: 'ongs', as: :contact

  # Channels
  constraints SubdomainConstraint do
    namespace :channels, path: '' do
      get '/supported_by_channel', to: 'projects#supported_by_channel', format: :json

      namespace :admin do
        namespace :reports do
          resources :subscriber_reports, only: [ :index ]
        end
        resources :posts
        resources :partners
        resources :images
        resources :followers, only: [ :index ]
      end

      resources :posts
      get '/', to: 'profiles#show', as: :profile
      get '/how-it-works', to: 'profiles#how_it_works', as: :about
      get '/terms', to: 'profiles#terms', as: :terms
      get '/privacy', to: 'profiles#privacy', as: :privacy
      get '/contacts', to: 'profiles#contacts', as: :contacts
      resource :profile
      # NOTE We use index instead of create to subscribe comming back from auth via GET
      resource :channels_subscriber, only: [:show, :destroy], as: :subscriber
    end
  end

  post '/moip/donator/notification', to: 'donators#moip_notification'

  # Root path should be after channel constraints
  root to: 'projects#index'

  get "/explore" => "explore#index", as: :explore

  namespace :reports do
    resources :contribution_reports_for_project_owners, only: [:index]
  end

  # Feedback form
  resources :feedbacks, only: [:create]

  namespace :admin do
    resources :home_banners, only: [:index, :new, :create, :destroy, :edit, :update]

    resources :projects, only: [ :index, :update, :destroy ] do
      member do
        put 'approve'
        get 'deny'
        put 'reject'
        put 'push_to_draft'
        put 'push_to_trash'
      end
    end

    resources :categories, except: [ :show, :destroy ]
    resources :statistics, only: [ :index ]
    resources :financials, only: [ :index ]
    resources :site_partners
    resources :channels, except: [ :show, :destroy ] do
      resources :users, controller: 'channels/users', only: [:create, :destroy]
    end
    resources :presses
    resource :transparency_report, only: [:show, :update]

    resources :contributions, only: [ :index, :update, :show ] do
      member do
        get :second_slip
        put 'confirm'
        put 'pendent'
        put 'change_reward'
        put 'refund'
        put 'hide'
        put 'cancel'
        put 'request_refund'
        put 'push_to_trash'
      end
    end
    resources :users, only: [ :index ]

    namespace :reports do
      resources :contribution_reports, only: [ :index ]
    end

    resources :pages, only: [:show, :update, :edit, :index]
  end

  get "/:permalink" => "projects#show", as: :project_by_slug

end
