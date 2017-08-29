# frozen_string_literal: true

class Api::V1::FavouriteTagsController < Api::BaseController

  before_action :set_account
  before_action -> { doorkeeper_authorize! :read }, only: [:index]
  before_action -> { doorkeeper_authorize! :write }, except: [:index]
  before_action :require_user!

  respond_to :json

  def index
    @favourite_tags = current_account.favourite_tags.includes(:tag).map(&:to_json_for_api)
    render json: @favourite_tags
  end

  def create
    tag = find_tag
    @favourite_tag = @account.favourite_tags.where(tag: tag).where.not(visibility: favourite_tag_visibility).first
    @favourite_tag.destroy unless @favourite_tag.nil?
    @favourite_tag = FavouriteTag.new(account: @account, tag: tag, visibility: favourite_tag_visibility)
    if @favourite_tag.save
      index
    else
      render json: current_account.favourite_tags.includes(:tag).map(&:to_json_for_api), status: :conflict
    end
  end

  def destroy
    tag = find_tag
    @favourite_tag = @account.favourite_tags.find_by(tag: tag)
    @favourite_tag.destroy unless @favourite_tag.nil?
    index
  end

  private

  def tag_params
    params.permit(:tag, :visibility)
  end

  def set_account
    @account = current_user.account
  end

  def find_tag
    Tag.find_or_initialize_by(name: tag_params[:tag])
  end

  def favourite_tag_visibility
    tag_params[:visibility].nil? ? 'public' : tag_params[:visibility]
  end
end
