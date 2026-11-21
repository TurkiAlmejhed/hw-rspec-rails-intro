class Movie < ApplicationRecord
  def self.all_ratings
    %w[G PG PG-13 R]
  end

  def self.with_ratings(ratings, sort_by)
    if ratings.nil?
      all.order sort_by
    else
      where(rating: ratings.map(&:upcase)).order sort_by
    end
  end

  def self.find_in_tmdb(search_terms)
    url = 'https://api.themoviedb.org/3/search/movie'

    query_params = {
      api_key: ENV['TMDB_API_KEY'],
      query: search_terms[:title]
    }

    if search_terms[:release_year].present?
      query_params[:year] = search_terms[:release_year]
    end

    response = Faraday.get(url, query_params)

    unless response.success?
      Rails.logger.error("TMDb API request failed: HTTP #{response.status}")
      return []
    end

    data = JSON.parse(response.body)
    results = data.fetch('results', [])

    if search_terms[:language] == 'en'
      results = results.select do |movie|
        movie['original_language'] == 'en'
      end
    end

    results.filter_map do |movie|
      result = Movie.new(
        title: movie['title'],
        release_date: movie['release_date'],
        rating: 'R'
      )

      unless Movie.exists?(
        title: result.title,
        release_date: result.release_date
      )
        result
      end
    end
  end
end