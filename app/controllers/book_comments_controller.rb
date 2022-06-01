class BookCommentsController < ApplicationController
  def create
    @book = Book.find(params[:book_id])
    @comment = current_user.book_comments.new(book_comment_params)
    @comment.book_id = @book.id
    respond_to do |format|
      if @comment.save
        format.html { redirect_back(fallback_location: root_path) }
        format.js
      else
        format.html { redirect_back(fallback_location: root_path) }
      end
    end
  end

  def destroy
    BookComment.find(params[:id]).destroy
    @book = Book.find(params[:book_id])
    render :book_comments
  end

  private

  def book_comment_params
    params.require(:book_comment).permit(:comment)
  end
end
