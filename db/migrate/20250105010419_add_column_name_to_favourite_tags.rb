# frozen_string_literal: true

require Rails.root.join('lib', 'mastodon', 'migration_helpers')

class AddColumnNameToFavouriteTags < ActiveRecord::Migration[7.0]
  include Mastodon::MigrationHelpers
  disable_ddl_transaction!

  def change
    safety_assured do
      add_column :favourite_tags, :name, :string
      change_column_null :favourite_tags, :tag_id, true
    end
  end
end
