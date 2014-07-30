class User < ActiveRecord::Base
  validates :username, :presence => {:message => "is required"}
  validates :username, :uniqueness => {:message => "has already been taken"}
  validates :password, :presence => {:message => "is required"}
  validates :password, :length => {minimum: 4, message: "must be at least 4 characters"}
end