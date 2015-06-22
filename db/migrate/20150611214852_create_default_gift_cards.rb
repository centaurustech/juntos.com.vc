class CreateDefaultGiftCards < ActiveRecord::Migration
  def change
    create_table :default_gift_cards do |t|
      t.references :gift_card_category, index: true
      t.string :name
      t.string :title
      t.text :description
      t.string :image

      t.timestamps
    end
  end
end
