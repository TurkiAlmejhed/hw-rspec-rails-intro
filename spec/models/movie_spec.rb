require 'rails_helper'
require 'spec_helper'

describe Movie do
  describe 'searching TMDB by keyword' do
    it 'calls Faraday gem' do
      expect(Faraday).to receive(:get)
        .and_return(double('response', success?: true, body: '{"results":[]}'))

      Movie.find_in_tmdb({title: "hacker", language: "en"})
    end
  end

  it 'calls TMDb with valid API key' do
  Movie.find_in_tmdb({title: "hacker", language: "en"})
  end

  it 'returns an empty list when no movies are found' do
  stub_request(:get, /api.themoviedb.org/)
    .to_return(
      status: 200,
      body: '{"results":[]}',
      headers: {}
    )

  results = Movie.find_in_tmdb({
    title: "nonexistentmovie",
    language: "en"
  })

  expect(results).to eq([])
  end


  it 'handles an invalid API key' do
  stub_request(:get, /api.themoviedb.org/)
    .to_return(
      status: 401,
      body: '{"success":false,"status_message":"Invalid API key"}',
      headers: {}
    )

  results = Movie.find_in_tmdb({
    title: "hacker",
    language: "en"
  })

  expect(results).to eq([])
  end
end