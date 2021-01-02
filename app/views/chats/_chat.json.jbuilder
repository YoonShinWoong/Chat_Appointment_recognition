json.extract! chat, :id, :post_id, :body, :created_at, :updated_at
json.url chat_url(chat, format: :json)
