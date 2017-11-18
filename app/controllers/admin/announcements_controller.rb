# frozen_string_literal: true

module Admin
  class AnnouncementsController < BaseController
    before_action :set_announcements

    def index
      @announcement = Announcement.new
    end

    def edit
      @announcement = Announcement.find(params[:id])
      @announcement.link = json_to_link(@announcement.link)
      render :index
    end

    def create
      if params[:announcement][:id].blank?
        @announcement = Announcement.new(resource_params)
      else
        @announcement = Announcement.find(params[:announcement][:id])
        @announcement.attributes = resource_params
      end
      @announcement.link = link_to_json(@announcement.link)

      if @announcement.save
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

    def link_param_to_hash(value)
      {
        url: value[0],
        name: value[1],
        is_outer_link: value[0].start_with?('http'),
      }
    end

    def link_to_json(value)
      if value.blank?
        nil
      else
        value.lines.map { |line| link_param_to_hash(line.chomp.split('|')) }
      end
    end

    def json_to_link(value)
      if value.blank?
        value
      else
        value.map { |link| link.values.shift(2).join('|') }.join("\r\n")
      end
    end

    def resource_params
      params.require(:announcement).permit(:id, :title, :body, :link)
    end

    def set_announcements
      @announcements = Announcement.where(disabled: false).order(:id)
    end
  end
end
