class CreateJuntosGiftCards < ActiveRecord::Migration
  def change
    create_table :juntos_gift_cards do |t|
      t.references :gift_purchase, index: true
      t.references :default_gift_card, index: true
      t.references :contribution, index: true
      t.references :user, index: true
      t.string :title
      t.string :image
      t.text :description
      t.string :email
      t.boolean :anonymous
      t.references :project, index: true
      t.string :code
      t.decimal :value

      t.timestamps
    end
  end
end
