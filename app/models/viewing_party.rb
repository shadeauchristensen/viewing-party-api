class ViewingParty < ApplicationRecord
    has_many :viewing_party_users
    has_many :users, through: :viewing_party_users

    validates :name, :start_time, :end_time, :movie_id, :movie_title, presence: true
end
