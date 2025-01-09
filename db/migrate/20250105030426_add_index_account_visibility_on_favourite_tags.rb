# frozen_string_literal: true

require Rails.root.join('lib', 'mastodon', 'migration_helpers')

class AddIndexAccountVisibilityOnFavouriteTags < ActiveRecord::Migration[7.0]
  include Mastodon::MigrationHelpers
  disable_ddl_transaction!

  def change
    safety_assured do
      add_index :favourite_tags, [:account_id, :name, :visibility], unique: true
    end
  end
end
