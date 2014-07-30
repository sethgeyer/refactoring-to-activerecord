class Fish < ActiveRecord::Base
 validates :name, :wikipedia_page, presence: {message: "is required"}
end