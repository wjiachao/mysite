class HomeController < ApplicationController
  def index
    @post = Post.all.limit(3)
  end
end
