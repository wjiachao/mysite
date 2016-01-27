class PostsController < ApplicationController

  def index
    @post = Post.all
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
