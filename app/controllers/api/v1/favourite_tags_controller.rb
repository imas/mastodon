# frozen_string_literal: true

class Api::V1::FavouriteTagsController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read, :'read:statuses' }, only: [:index]
  before_action -> { doorkeeper_authorize! :write, :'write:statuses' }, except: [:index]
  before_action :require_user!

  respond_to :json

  def index
    current_account = current_user.account
    orderd_favourite_tags = current_account.favourite_tags.with_order

    render json: orderd_favourite_tags.map(&:to_json_for_api)
  end

  def create
    current_account = current_user.account
    favourite_tag = current_account.favourite_tags.find_by(name: create_params[:name], visibility: create_params[:visibility])

    if favourite_tag.present?
      render json: favourite_tag.to_json_for_api, status: 409
      return
    end

    favourite_tag = FavouriteTag.new(account: current_account, name: create_params[:name], visibility: create_params[:visibility])
    favourite_tag.save!
    render json: favourite_tag.to_json_for_api
  end

  def destroy
    current_account = current_user.account
    favourite_tag = current_account.favourite_tags.find_by(id: params[:id])
    if favourite_tag.nil?
      render json: { error: 'FavouriteTag is not found' }, status: 404
    else
      favourite_tag.destroy!
    end
  end

  private

  def create_params
    params.permit(:name, :visibility)
    params[:visibility] ||= 'public'
    params
  end
end
