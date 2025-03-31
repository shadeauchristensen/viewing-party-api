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

    def self.details(movie, cast, reviews)
        {
            data: {
                id: movie[:id].to_s,
                type: "movie",
                attributes: {
                    title: movie[:title],
                    release_year: movie[:release_date][0..3].to_i,
                    vote_average: movie[:vote_average],
                    runtime: format_runtime(movie[:runtime]),
                    genres: movie[:genres].map { |g| g[:name] },
                    summary: movie[:overview],
                        cast: format_cast(cast),
                            total_reviews: reviews[:results].count,
                            reviews: format_reviews(reviews[:results])
                }
            }

        }
    end

    def self.format_runtime(minutes)
        hour_amount = minutes / 60
        minute_amount = minutes % 60
        "#{hour_amount} hours and #{minute_amount} minutes"
    end

    def self.format_cast(cast_array)
        cast_array.first(10).map do |person|
            {
                character: person[:character],
                actor: person[:name]
            }
        end
    end

    def self.format_reviews(review_array)
        review_array.first(5).map do |review|
            {
                author: review[:author],
                review: review[:content]
            }
        end
    end
end