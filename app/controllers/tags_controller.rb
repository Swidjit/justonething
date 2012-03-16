class TagsController < ApplicationController

  def autocomplete_search
    new_tag = params[:q].downcase.gsub(' ','-')
    @tags = Tag.where("name like ?", "%#{new_tag}%")

    if !@tags.collect(&:name).include? new_tag
      @tags << Tag.new(:name => new_tag)
    end
    respond_to do |format|
      format.json { render :json => @tags.collect{|tag| {:id => tag.name, :name => tag.name}} }
    end
  end

end
