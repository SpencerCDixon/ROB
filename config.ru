require_relative 'rod'

app = ROB::Application.new

app.routes do
  get '/', to: 'example#index'
  get '/example', to: 'example#example_two'
end

run app, port: 6969


