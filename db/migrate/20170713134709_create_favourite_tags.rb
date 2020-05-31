class CreateFavouriteTags < ActiveRecord::Migration[5.1]
  def change
    create_table :favourite_tags do |t|
      t.bigint :account_id, null: false
      t.bigint :tag_id, null: false
      t.index [:account_id, :tag_id], unique: true
      t.foreign_key :accounts, on_delete: :cascade
      t.foreign_key :tags, on_delete: :cascade
      t.timestamps
    end
  end
end
