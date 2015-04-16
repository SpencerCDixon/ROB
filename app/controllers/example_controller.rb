class ExampleController < ApplicationController
  def index
  end

  def example_two
    haml :example_two, locals: { test: 'test' }
  end

  def home_page
    render_with_layout :layout_page, :sample_layout
  end
end
