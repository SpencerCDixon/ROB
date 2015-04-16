class ExampleController < ApplicationController
  def index
  end

  def example_two
    haml :example_two, locals: { test: 'test' }
  end

  def home_page
    erb :home_page, locals: { name: 'spencer' }
  end
end
