class Api::V1::MoviesController < ApplicationController
    def index
        begin
            if params[:query]
                data =  MovieDbService.search_movies(params[:query])[:results]
            else
                data = MovieDbService.top_rated_movies[:results]
            end

            if data.nil? || data.empty?
                render json: { error: "Movie data invalid, cannot return #{params[:query].presence || "nil"}" }, status: :bad_request
            else                
                movies = data.first(20)
                render json: MovieSerializer.format_movies(movies)
            end

        rescue => error
                render json: { error: "Unexpected error occurred: #{error.message}" }, status: :internal_server_error
        end
    end

    def show
        begin
            movie_id = params[:id]

            movie = MovieDbService.movie_details(movie_id)
            cast = MovieDbService.movie_credits(movie_id)[:cast]
            reviews = MovieDbService.movie_reviews(movie_id)

            render json: MovieSerializer.details(movie, cast, reviews)

        rescue => error
            render json: { error: "Something went wrong: Must be a valid movie ID" }, status: :internal_server_error
        end
    end
end