class Tag < ApplicationRecord
  has_many :tagmaps, dependent: :destroy
  has_many :books, through: :tagmaps
end
