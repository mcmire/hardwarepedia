
Hardwarepedia::Application.routes.draw do
  # *** Remember, routes that are higher up take precedence! ***

  root :to => 'main#index'
  resources :products
end
