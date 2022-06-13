class BooksController < ApplicationController

  def create
    @book = Book.new(book_params)
    tag_list = params[:book][:tag_name].split(nil)
    @book.user_id = current_user.id
    if @book.save
      @book.save_books(tag_list)
      redirect_to book_path(@book.id), notice: "You have created book successfully."
    else
      @books = Book.all
      render :index
    end
  end

  def index
    if params[:latest]
      @books = Book.latest
    elsif params[:star_count]
      @books = Book.star_count
    else
      @books = Book.all
    end
    @book = Book.new
    if params[:search].present?
      books = Book.books_search(params[:search])
    elsif params[:tag_id].present?
      @tag = Tag.find(params[:tag_id])
      books = @tag.books.order(created_at: :desc)
    else
      books = Book.all.order(created_at: :desc)
    end
    @tag_lists = Tag.all
  end

  def show
    @new_book = Book.new
    @book = Book.find(params[:id])
    @user = @book.user
    @book_comment = BookComment.new
    @book_comments = @book.book_comments.all
  end

  def edit
    @book = Book.find(params[:id])
    if @book.user == current_user
      render :edit
    else
      redirect_to books_path
    end
  end

  def update
    @book = Book.find(params[:id])
    if @book.update(book_params)
      redirect_to book_path(@book.id), notice: "You have updated book successfully."
    else
      render :edit
    end
  end

  def destroy
    @book = Book.find(params[:id])
    @book.destroy
    redirect_to books_path
  end

  private

  def book_params
    params.require(:book).permit(:title, :body, :profile_image, :rate)
  end
end
