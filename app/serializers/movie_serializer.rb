class MovieSerializer
    def self.format_movies(movie_data_array)
        movie_data_array.map do | movie |
            {
                id: movie[:id].to_s,
                type: "movie",
                attributes: {
                    title: movie[:title],
                    vote_average: movie[:vote_average]
                }
            }
        end
    end
end