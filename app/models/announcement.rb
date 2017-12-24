# frozen_string_literal: true
# == Schema Information
#
# Table name: announcements
#
#  id         :integer          not null, primary key
#  title      :string           default(""), not null
#  body       :text             default(""), not null
#  link       :json
#  disabled   :boolean          default(FALSE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Announcement < ApplicationRecord
  validates :title, :body, presence: true

  def save_for_view
    self.link = link_to_json(self.link)
    save
  end

  def json_to_link
    if self.present? and self.link.present?
      self.link = self.link.map { |link| link.values[1].blank? ? link.values[0] : link.values.shift(2).join('|') }.join("\r\n")
    end
    self
  end

  private

  # 永続化の際のjsonの形式
  def link_param_to_hash(value)
    {
      url: value[0],
      name: value[1],
      is_outer_link: value[0].start_with?('http'),
    }
  end

  def link_to_json(value)
    if value.blank?
      value
    else
      value = link.lines.map { |line| link_param_to_hash(line.chomp.split('|')) }
    end
  end

end
