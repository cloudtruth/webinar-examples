require 'bundler'
Bundler.require
Dotenv.load

configure do
    set :root, File.dirname(__FILE__)
    set :public_folder, 'public'
end

configure :development do
    register Sinatra::Reloader
end

get '/'  do
    @myenv = ENV.select {|k, v| k.start_with? 'APP_'}
    erb :index
end
