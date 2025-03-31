require "rails_helper"

RSpec.describe "Top rated movies API", type: :request do
    describe "GET api/v1/movies" do
        it "HAPPY PATH: returns the top 20 highest rated movies", :vcr do
            get "/api/v1/movies"

            expect(response).to be_successful

            json = JSON.parse(response.body, symbolize_names: true)

            expect(json).to be_an(Array)
            expect(json.count).to eq(20)

            json.each do | movie |
                expect(movie).to have_key(:id)
                expect(movie[:type]).to eq("movie")
                expect(movie[:attributes]).to have_key(:title)
                expect(movie[:attributes]).to have_key(:vote_average)
            end
        end

        it "SAD PATH: returns errors if failed to retrieve the top 20" do
            allow(MovieDbService).to receive(:top_rated_movies).and_return({ results: nil })

            get "/api/v1/movies"

            expect(response).not_to be_successful
            expect(response).to have_http_status(:bad_request)

            json = JSON.parse(response.body, symbolize_names: true)
            
            
            expect(json).to have_key(:error)
            expect(json[:error]).to eq("Movie data invalid, cannot return nil")            
        end

        it "SAD PATH: returns 500 error if unexpected error occurs" do
            allow(MovieDbService).to receive(:top_rated_movies).and_raise(StandardError.new("Something went wrong"))

            get "/api/v1/movies"

            expect(response).to have_http_status(:internal_server_error)

            json = JSON.parse(response.body, symbolize_names: true)

            expect(json).to have_key(:error)
            expect(json[:error]).to eq("Unexpected error occurred: Something went wrong")
        end

        it "HAPPY PATH: returns up to 20 movies matching search params", :vcr do
            get "/api/v1/movies?query=ring"

            expect(response).to be_successful

            json = JSON.parse(response.body, symbolize_names: true)

            expect(json).to be_an(Array)
            expect(json.count).to be <= 20

            json.each do | movie |
                expect(movie).to have_key(:id)
                expect(movie[:type]).to eq("movie")
                expect(movie[:attributes]).to have_key(:title)
                expect(movie[:attributes]).to have_key(:vote_average)
            end
        end

        it "SAD PATH: returns errors if failed to retrieve title" do
            allow(MovieDbService).to receive(:search_movies).and_return({ results: nil })

            get "/api/v1/movies?query="

            expect(response).not_to be_successful
            expect(response).to have_http_status(:bad_request)

            json = JSON.parse(response.body, symbolize_names: true)
            
            
            expect(json).to have_key(:error)
            expect(json[:error]).to eq("Movie data invalid, cannot return nil")            
        end

        it "SAD PATH: returns errors if no title exists" do
            search_term = "gibberish123456"

            allow(MovieDbService).to receive(:search_movies).with(search_term).and_return({ results: [] })

            get "/api/v1/movies?query=#{search_term}"

            expect(response).not_to be_successful
            expect(response).to have_http_status(:bad_request)

            json = JSON.parse(response.body, symbolize_names: true)
            
            
            expect(json).to have_key(:error)
            expect(json[:error]).to eq("Movie data invalid, cannot return #{search_term}")            
        end

        it "SAD PATH: returns 500 error if unexpected error occurs" do
            allow(MovieDbService).to receive(:search_movies).and_raise(StandardError.new("Something went wrong"))

            get "/api/v1/movies?query=mock_movie_title"

            expect(response).to have_http_status(:internal_server_error)

            json = JSON.parse(response.body, symbolize_names: true)

            expect(json).to have_key(:error)
            expect(json[:error]).to eq("Unexpected error occurred: Something went wrong")
        end
    end

    describe "GET /api/v1/movies/:id" do
        it "HAPPY PATH: returns details for a valid movie", :vcr do
            get "/api/v1/movies/278"

            expect(response).to be_successful

            movie = JSON.parse(response.body, symbolize_names: true)

            movie_attributes = movie[:data][:attributes]

            expect(movie[:data]).to have_key(:id)
            expect(movie_attributes[:title]).to eq("The Shawshank Redemption")
            expect(movie_attributes[:cast].count).to be <= 10
            expect(movie_attributes[:reviews].count).to be <= 5

        end

        it "SAD PATH: returns a 500 error if there isn't a valid movie ID" do
            get "/api/v1/movies/0"

            expect(response.status).to eq(500)

            error = JSON.parse(response.body, symbolize_names: true)

            expect(error).to have_key(:error)
            expect(error[:error]).to eq("Something went wrong: Must be a valid movie ID")
        end
    end
end