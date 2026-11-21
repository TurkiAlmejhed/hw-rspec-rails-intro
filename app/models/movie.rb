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

    if search_terms[:language] == 'en'
      query_params[:language] = 'en-US'
    end

    response = Faraday.get(url, query_params)

    return [] unless response.success?

    data = JSON.parse(response.body)

    data['results'].map do |movie|
      Movie.new(
        title: movie['title'],
        release_date: movie['release_date'],
        rating: 'R'
      )
    end
  end

end
