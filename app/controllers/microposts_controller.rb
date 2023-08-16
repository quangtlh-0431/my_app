class MicropostsController < ApplicationController
  def index
    micropost = Micropost.new(name: "quang", content: "abc")
    micropost.save
    @microposts = Micropost.all
  end
end
