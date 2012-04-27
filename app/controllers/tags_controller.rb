class TagsController < ApplicationController
  def autocomplete_search
    @tag_class = Tag
    load_tags

    respond_to do |format|
      format.json { render :json => @tags.collect{|tag| {:id => tag.name, :name => tag.name}} }
    end
  end

  def autocomplete_search_geo
    @tag_class = GeoTag
    load_tags

    respond_to do |format|
      format.json { render :json => @tags.collect{|tag| {:id => tag.name, :name => tag.name}} }
    end
  end

private

  def load_tags
    new_tag = params[:q].downcase.strip.gsub(' ','-')
    @tags = @tag_class.where("name like ?", "%#{new_tag}%")

    @tags << @tag_class.new(:name => new_tag) unless @tags.map(&:name).include?(new_tag)
  end
end
