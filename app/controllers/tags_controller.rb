class TagsController < ApplicationController

  def autocomplete_search
    @tags = Tag.where("name like ?", "%#{params[:q]}%")
    if !@tags.collect(&:name).include? params[:q]
      @tags << Tag.new(:name => params[:q])
    end
    respond_to do |format|
      format.json { render :json => @tags.collect{|tag| {:id => tag.name, :name => tag.name}} }
    end
  end

end
