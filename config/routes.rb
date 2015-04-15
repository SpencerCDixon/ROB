BroApp.routes do
  root to: 'example#home_page'
  get '/example', to: 'example#example_two'
end
