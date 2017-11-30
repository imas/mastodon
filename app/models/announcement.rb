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
end
