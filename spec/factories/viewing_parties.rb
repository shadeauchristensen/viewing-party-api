FactoryBot.define do
    factory :viewing_party do
        name { "Juliet's Bday Movie Bash!" }
        start_time { "2025-02-01 10:00:00" }
        end_time { "2025-02-01 14:30:00" }
        movie_id { 278 }
        movie_title { "The Shawshank Redemption" }
    end
end