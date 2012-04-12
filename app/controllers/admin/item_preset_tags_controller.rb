class Admin::ItemPresetTagsController < Admin::ApplicationController

  authorize_resource

  def index
    @item_preset_tags = ItemPresetTag.all
  end

  def new
    @item_preset_tag = ItemPresetTag.new
  end

  def create
    @item_preset_tag = ItemPresetTag.create(params[:item_preset_tag])
    if @item_preset_tag.valid?
      redirect_to item_preset_tags_path
    else
      render :new
    end
  end

  def destroy
    @item_preset_tag = ItemPresetTag.find(params[:id])
    @item_preset_tag.destroy
    redirect_to item_preset_tags_path
  end
end
