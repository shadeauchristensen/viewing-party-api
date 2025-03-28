class Api::V1::MoviesController < ApplicationController
    def index
        begin
            if params[:query]
                data =  MovieDbService.search_movies(params[:query])[:results]
            else
                data = MovieDbService.top_rated_movies[:results]
            end

            if data.nil?
                render json: { error: "Movie data invalid, cannot return nil" }, status: :bad_request
            else                
                movies = data.first(20)
                render json: MovieSerializer.format_movies(movies)
            end

        rescue => error
                render json: { error: "Unexpected error occurred: #{error.message}" }, status: :internal_server_error
        end
    end
end