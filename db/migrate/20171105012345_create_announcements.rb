class CreateAnnouncements < ActiveRecord::Migration[5.1]
  def change
    create_table :announcements, id: :bigint do |t|
      t.string :title, null: false, default: ''
      t.text :body, null: false, default: ''
      t.json :link
      t.boolean :disabled, null: false, default: false
      t.timestamps
    end
  end
end
