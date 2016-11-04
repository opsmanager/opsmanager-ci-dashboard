require 'dashing'

configure do

  Dir["config/initializers/**/*.rb"].sort.each do |config_file_path|
    require File.join(Dir.pwd, config_file_path)
  end

  helpers do
    def protected!
      # Put any authentication code you want in here.
      # This method is run before accessing any resource.
    end
  end
end

map Sinatra::Application.assets_prefix do
  run Sinatra::Application.sprockets
end

run Sinatra::Application
