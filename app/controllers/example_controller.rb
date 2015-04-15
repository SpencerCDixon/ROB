class ExampleController < ApplicationController
  def index
    'index text'
  end

  def example_two
    'this is example two text'
  end

  def home_page
    erb :home_page, locals: { name: 'spencer' }
  end
end
