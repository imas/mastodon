# == Schema Information
#
# Table name: Announcements
#
#  id         :integer          not null, primary key
#  title      :string           not null
#  body       :text             not null
#  link       :json
#  disabled   :boolean          default(FALSE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Announcement < ApplicationRecord

  validates :title, :body, presence: true

end
