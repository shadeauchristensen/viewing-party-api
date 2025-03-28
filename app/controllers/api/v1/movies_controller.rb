class Api::V1::MoviesController < ApplicationController
    def index
        movies = MovieDbService.top_rated_movies[:results].first(20)

        render json: MovieSerializer.format_movies(movies)
    end
end