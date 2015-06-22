class AddGiftToContributions < ActiveRecord::Migration
  def change
    add_column :contributions, :gift, :boolean, default: false
  end
end
