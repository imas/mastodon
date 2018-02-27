# frozen_string_literal: true

class REST::AnnouncementSerializer < ActiveModel::Serializer
  attributes :id, :body, :is_new
  has_many :links, serializer: REST::AnnouncementLinkSerializer

  def is_new
    Time.zone.now.ago(2.days) < object.updated_at
  end
end
