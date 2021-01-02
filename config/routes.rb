Rails.application.routes.draw do

  root 'posts#index'

  resources :chats
  resources :posts, shallow: true do
    resources :chats
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  get 'chats/new/:post_id' => 'chats#new'
end
