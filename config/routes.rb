
Hardwarepedia::Application.routes.draw do
  # *** Remember, routes that are higher up take precedence! ***

  root :to => 'main#index'

  resources :reviewables, :except => :show
  get '/reviewables/:webkey', :to => 'reviewables#show', :as => :reviewable
end
