class Post < ApplicationRecord
    has_many :chats
    has_many :alarms
end
