class User < ActiveRecord::Base
  validates :username, :presence => {:message => "Username is required"}
  validates :username, :length => {minimum: 4}
  validates :username, :uniqueness => {:message => "Username has already been taken"}
  validates :password, :presence => {:message => "Password is required"}
  validates :password, :length => {minimum: 4, message: "Password must be at least 4 characters"}
end