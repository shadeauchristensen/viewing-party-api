class MovieDbService
    def self.conn
      Faraday.new(url: "https://api.themoviedb.org/3/") do |faraday|
        faraday.headers["Authorization"] = "Bearer #{Rails.application.credentials.movie_db[:key]}"
      end
    end
  
    def self.top_rated_movies
      response = conn.get("movie/top_rated")
      JSON.parse(response.body, symbolize_names: true)
    end

    def self.search_movies(query)
        response = conn.get("search/movie", { query: query })
        JSON.parse(response.body, symbolize_names: true)
    end

    def self.movie_details(movie_id)
      response = conn.get("movie/#{movie_id}")
      JSON.parse(response.body, symbolize_names: true)
    end
  end
end