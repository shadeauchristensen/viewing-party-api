class Api::V1::MoviesController < ApplicationController
    def index
        movies = MovieDbService.top_rated_movies[:results].first(20)

        render json: movies.map { |movie| {
            id: movie[:id].to_s,
            type: "movie",
            attributes: {
                title: movie[:title],
                vote_average: movie[:vote_average]
            }
        } 
    }
    end
end