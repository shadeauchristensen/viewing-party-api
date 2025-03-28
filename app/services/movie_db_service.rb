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
  end