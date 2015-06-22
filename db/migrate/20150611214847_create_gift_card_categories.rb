class CreateGiftCardCategories < ActiveRecord::Migration
  def change
    create_table :gift_card_categories do |t|
      t.string :name

      t.timestamps
    end
  end
end
