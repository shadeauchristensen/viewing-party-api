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

            puts response.status
            puts response.body

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
    end
end