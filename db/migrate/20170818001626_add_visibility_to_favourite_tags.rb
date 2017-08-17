class AddVisibilityToFavouriteTags < ActiveRecord::Migration[5.1]
  def change
    add_column :favourite_tags, :visibility, :string, null: false, default: ""

    FavouriteTag.update_all(visibility: "public")
  end
end
