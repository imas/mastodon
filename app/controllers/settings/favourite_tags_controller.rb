# frozen_string_literal: true

class Settings::FavouriteTagsController < Settings::BaseController
  layout 'admin'
  before_action :authenticate_user!

  def index
    @favourite_tags = current_account.favourite_tags.with_order
    @favourite_tag = FavouriteTag.new(visibility: FavouriteTag.visibilities[:public])
  end

  def edit
    @favourite_tag = current_account.favourite_tags.find(params[:id])
  end

  def create
    @favourite_tag = FavouriteTag.new(
      account: current_account,
      name: create_params[:name].delete_prefix('#'),
      order: create_params[:order],
      visibility: create_params[:visibility]
    )

    if @favourite_tag.save
      redirect_to settings_favourite_tags_path, notice: I18n.t('generic.changes_saved_msg')
    else
      @favourite_tags = current_account.favourite_tags.with_order
      render :index
    end
  end

  def update
    @favourite_tag = current_account.favourite_tags.find(params[:id])

    @favourite_tag.update(
      name: update_params[:name].delete_prefix('#'),
      order: update_params[:order],
      visibility: update_params[:visibility]
    )

    if @favourite_tag.save
      redirect_to settings_favourite_tags_path, notice: I18n.t('generic.changes_saved_msg')
    else
      render :edit
    end
  end

  def destroy
    current_account.favourite_tags.destroy(params[:id])
    redirect_to settings_favourite_tags_path
  end

  private

  def create_params
    params.require(:favourite_tag).permit(:name, :visibility, :order)
  end

  def update_params
    params.require(:favourite_tag).permit(:name, :visibility, :order)
  end

  def current_account
    current_user.account
  end
end
