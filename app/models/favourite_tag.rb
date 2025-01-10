# frozen_string_literal: true

# == Schema Information
#
# Table name: favourite_tags
#
#  id         :bigint(8)        not null, primary key
#  account_id :bigint(8)        not null
#  tag_id     :bigint(8)        not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  visibility :integer          default("public"), not null
#  order      :integer          default(0), not null
#  name       :string
#

class FavouriteTag < ApplicationRecord
  enum :visibility, { public: 0, unlisted: 1, private: 2, direct: 3 }, suffix: :visibility

  belongs_to :account, optional: false
  belongs_to :tag, optional: true

  validates :name, format: { with: Tag::HASHTAG_NAME_RE }, uniqueness: { scope: [:account, :visibility] }
  validates :visibility, presence: true
  validates :order, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :with_order, -> { order(order: :desc, id: :asc) }

  def to_json_for_api
    {
      id: id,
      name: name,
      visibility: visibility,
    }
  end

  def migrate_tag_name!
    return if name.present?

    update!(name: tag&.name)
  end
end
