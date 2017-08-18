# frozen_string_literal: true

class Api::V1::FavouriteTagsController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read }
  before_action :require_user!

  respond_to :json

  def index
    @tags = current_account.favourite_tags.includes(:tag)
      .pluck(:id, :name, :visibility).map { |p| { id: p[0], name: p[1], visibility: p[2] } }
    render json: @tags
  end
end
