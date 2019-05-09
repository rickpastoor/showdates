# frozen_string_literal: true

class AboutController < ShowdatesApp
  get '/terms' do
    @title = 'Terms '
    erb :about_terms
  end

  get '/privacy' do
    erb :about_privacy
  end
end
