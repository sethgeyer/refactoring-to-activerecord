require "sinatra"
require "gschool_database_connection"
require "rack-flash"
require_relative "lib/user"
require_relative "lib/fish"

class App < Sinatra::Application
  enable :sessions
  use Rack::Flash

  def initialize
    super
    @database_connection = GschoolDatabaseConnection::DatabaseConnection.establish(ENV["RACK_ENV"])
  end

  get "/" do
    user = current_user

    if current_user
      users = User.where('id != ?', session[:user_id])
      fish = Fish.where(user_id: current_user.id)
      erb :signed_in, locals: {current_user: user, users: users, fish_list: fish}
    else
      erb :signed_out, locals: {user: nil}
    end
  end

  get "/register" do
    erb :register
  end

  post "/registrations" do
    user = User.new
    user.username = params[:username]
    user.password = params[:password]

    if user.save
      flash[:notice] = "Thanks for registering"
      redirect "/"
    else
      flash[:notice] =  ""
      user.errors.full_messages.each do |message|
        flash[:notice] += message
      end
      erb :register
    end
  end

  delete "/sessions" do
    session[:user_id] = nil
    redirect "/"
  end

  delete "/users/:id" do
    User.find(params[:id].to_i).destroy
    redirect "/"
  end

  get "/fish/new" do

    erb :"fish/new", locals: {fish: Fish.new}
  end

  get "/fish/:id" do
    fish = Fish.find(params[:id].to_i)
    erb :"fish/show", locals: {fish: fish}
  end

  post "/fish" do
    # if validate_fish_params
      fish = Fish.new
      fish.name = params[:name]
      fish.wikipedia_page = params[:wikipedia_page]
      fish.user_id = current_user.id
      if fish.save
        flash[:notice] = "Fish Created"
        redirect "/"
      else
        erb :"fish/new", locals: {fish: fish}
      end
  end

  private

  def validate_fish_params
    if params[:name] != "" && params[:wikipedia_page] != ""
      return true
    end

    error_messages = []

    if params[:name] == ""
      error_messages.push("Name is required")
    end

    if params[:wikipedia_page] == ""
      error_messages.push("Wikipedia page is required")
    end

    flash[:notice] = error_messages.join(", ")

    false
  end

  post "/sessions" do
    if validate_authentication_params
      user = User.find_by(username: params[:username], password: params[:password])
      if user != nil
        session[:user_id] = user["id"]
      else
        flash[:notice] = "Username/password is invalid"
      end
    end
    redirect "/"
  end


  def validate_authentication_params
    if params[:username] != "" && params[:password] != ""
      return true
    end

    error_messages = []

    if params[:username] == ""
      error_messages.push("Username is required")
    end

    if params[:password] == ""
      error_messages.push("Password is required")
    end

    flash[:notice] = error_messages.join(", ")

    false
  end


  def username_available?(username)
    existing_users = User.where(username: username)
    existing_users.length == 0
  end


  def current_user
    if session[:user_id]
      User.find(session[:user_id])
    else
      nil
    end
  end
end
