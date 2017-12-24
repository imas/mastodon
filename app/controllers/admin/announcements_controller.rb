# frozen_string_literal: true

module Admin
  class AnnouncementsController < BaseController
    before_action :set_announcements, except: [:destroy]
    before_action :set_announcement, only: [:show, :update]

    def index
      @announcement = Announcement.new
    end

    def show
      render :index
    end

    def create
      @announcement = Announcement.new(resource_params)
      if @announcement.save_for_view
        redirect_to admin_announcements_path, notice: I18n.t('generic.changes_saved_msg')
      else
        render :index
      end
    end

    def update
      @announcement.attributes = resource_params
      if @announcement.save_for_view
        redirect_to admin_announcements_path, notice: I18n.t('generic.changes_saved_msg')
      else
        render :index
      end
    end

    def destroy
      Announcement.find(params[:id]).update_attribute(:disabled, true)
      redirect_to admin_announcements_path, notice: I18n.t('generic.changes_saved_msg')
    end

    private

    def resource_params
      params.require(:announcement).permit(:title, :body, :link)
    end

    def set_announcement
      @announcement = Announcement.find(params[:id]).json_to_link
    end

    def set_announcements
      @announcements = Announcement.where(disabled: false).order(:id)
    end
  end
end
