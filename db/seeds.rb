# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
User.destroy_all #removes
ActiveRecord::Base.connection.reset_pk_sequence!('users') #starts back at id:1

ViewingParty.destroy_all
ActiveRecord::Base.connection.reset_pk_sequence!('viewing_parties')


User.create!(name: "Danny DeVito", username: "danny_de_v", password: "jerseyMikesRox7")
User.create!(name: "Dolly Parton", username: "dollyP", password: "Jolene123")
User.create!(name: "Lionel Messi", username: "futbol_geek", password: "test123")
User.create!(name: "Barbara", username: "leo_fan", password: "lotrRocks123")
User.create!(name: "Ceci", username: "titanic_forever", password: "icebergRightAhead")
User.create!(name: "Peyton", username: "star_wars_geek_8", password: "theForce2025")

party = ViewingParty.create!(
    name: "Test Party",
    start_time: Time.now,
    end_time: Time.now + 2.hours,
    movie_id: 278,
    movie_title: "The Shawshank Redemption"
)

ViewingPartyUser.create!(user: User.find(1), viewing_party: party, host: true)
ViewingPartyUser.create!(user: User.find(2), viewing_party: party, host: false)