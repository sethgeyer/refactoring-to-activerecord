class User < ActiveRecord::Base
  validates :username, :password, :presence => {:message => "is required"}
  validates :username, :uniqueness => {:message => "has already been taken"}
  validates :password, :length => {minimum: 4, message: "must be at least 4 characters"}
end