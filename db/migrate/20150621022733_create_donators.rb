class CreateDonators < ActiveRecord::Migration
  def change
    create_table :donators do |t|
      t.references :user, index: true
      t.string :key
      t.string :payment_engine
      t.string :plan_code
      t.string :fullname
      t.string :email
      t.string :customer_code # customer code in in paypal
      t.string :cpf
      t.date :birthdate
      t.string :phone_area_code
      t.string :phone_number
      t.string :street
      t.string :street_number
      t.string :street_complement
      t.string :district
      t.string :zipcode
      t.string :city
      t.string :uf
      t.string :status

      t.timestamps
    end
  end
end
