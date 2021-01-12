Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  #resource :articles
  get "/articles", to: "articles#index"
  get "/alfabeto", to: "articles#alphabet"


  get "/alphabet/letter/:letter", to: "articles#showletter"

  root 'articles#index'
end
