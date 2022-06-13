class Book < ApplicationRecord
  has_one_attached :profile_image
  belongs_to :user
  has_many :book_comments, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :tagmaps, dependent: :destroy
  has_many :tags, through: :tagmaps

  validates :title,presence:true
  validates :body,presence:true,length:{maximum:200}

  scope :latest, -> {order(created_at: :desc)}
  scope :star_count, -> {order(rate: :desc)}

  def get_profile_image(width, height)
    unless profile_image.attached?
      file_path = Rails.root.join('app/assets/images/no_image.jpg')
      profile_image.attach(io: File.open(file_path), filename: 'default-image.jpg', content_type: 'image/jpeg')
    end
    profile_image.variant(resize_to_limit: [width, height]).processed
  end

  def favorited_by?(user)
    favorites.exists?(user_id: user.id)
  end

  def self.looks(search, word)
    if search == "perfect_match"
      @book = Book.where("title LIKE?","#{word}")
    elsif search == "forward_match"
      @book = Book.where("title LIKE?","#{word}%")
    elsif search == "backward_match"
      @book = Book.where("title LIKE?","%#{word}")
    elsif search == "partial_match"
      @book = Book.where("title LIKE?","%#{word}%")
    else
      @book = Book.all
    end
  end

  def self.books_search(search)
    Book.where(['title LIKE ? OR body LIKE ?', "%#{search}%", "%#{search}%"])
  end

  def save_books(tags)
    current_tags = self.tags.pluck(:tag_name) unless self.tags.nil?
    old_tags = current_tags - tags
    new_tags = tags - current_tags
    old_tags.each do |old_name|
      self.tags.delete Tag.find_by(tag_name:old_name)
    end
    new_tags.each do |new_name|
      book_tag = Tag.find_or_create_by(tag_name:new_name)
      self.tags << book_tag
    end
  end
end
