class PostsController < ApplicationController

  def index
    get_page = params[:page].blank? ? 1 : params[:page]
    # @post = Post.all
    @posts = Post.all.order(publish_date: :desc).page(get_page).per(5)
  end

  def show
    @post = Post.find(params[:id])
    @content = @post.content.html_safe
  end

  private
    def post_params
      params.require(:post).permit(:title, :content, :created_at, :updated_at, :publish_date)
    end
end
