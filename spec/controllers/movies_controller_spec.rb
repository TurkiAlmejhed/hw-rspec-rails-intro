require 'rails_helper'

describe MoviesController, type: :controller do
  describe 'searching TMDb' do
    before :each do
      @fake_results = [double('movie1'), double('movie2')]
      @search_params = {
        title: 'hardware',
        release_year: '',
        language: 'en'
      }
    end

    it 'calls the model method that performs TMDb search' do
      expect(Movie).to receive(:find_in_tmdb)
        .with(@search_params)
        .and_return(@fake_results)

      get :search_tmdb, params: @search_params
    end

    describe 'after valid search' do
      before :each do
        allow(Movie).to receive(:find_in_tmdb)
          .and_return(@fake_results)

        get :search_tmdb, params: @search_params
      end

      it 'selects the Search Results template for rendering' do
        expect(response).to render_template('search_tmdb')
      end

      it 'makes the TMDb search results available to that template' do
        expect(assigns(:movies)).to eq(@fake_results)
      end
    end

    it 'displays an error when the title is missing' do
      expect(Movie).not_to receive(:find_in_tmdb)

      get :search_tmdb, params: { title: '' }

      expect(flash[:danger]).to eq(
        'Please fill in all required fields!'
      )
    end

    it 'displays an error when no movies are found' do
      allow(Movie).to receive(:find_in_tmdb).and_return([])

      get :search_tmdb, params: @search_params

      expect(flash[:warning]).to eq(
        'No movies found with given parameters!'
      )
    end
  end

  describe 'adding a movie' do
    before :each do
      @movie_params = {
        title: 'Manhunter',
        rating: 'R',
        release_date: '1986-08-14'
      }
    end

    it 'saves the movie to the database' do
      expect {
        post :add_movie, params: { movie: @movie_params }
      }.to change(Movie, :count).by(1)
    end

    it 'redirects to the search page' do
      post :add_movie, params: { movie: @movie_params }

      expect(response).to redirect_to(search_tmdb_path)
    end

    it 'displays a success message' do
      post :add_movie, params: { movie: @movie_params }

      expect(flash[:success]).to eq(
        'Manhunter was successfully added to RottenPotatoes.'
      )
    end
  end
end