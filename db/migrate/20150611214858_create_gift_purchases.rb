class CreateGiftPurchases < ActiveRecord::Migration
  def change
    create_table :gift_purchases do |t|
      t.references :user, index: true
      t.decimal :value
      t.text :key
      t.text :payment_token
      t.string :payment_engine
      t.string :state


      t.datetime :confirmed_at
      t.text :payment_method
      t.text :paymentid
      t.text :payer_name
      t.text :payer_email
      t.text :payer_document
      t.text :address_street
      t.text :address_number
      t.text :address_complement
      t.text :address_neighbourhood
      t.text :address_zip_code
      t.text :address_city
      t.text :address_state
      t.text :address_phone_number
      t.text :payment_choice
      t.decimal :payment_service_fee
      t.string :state
      t.text :address_country
      t.references :country, index: true
      t.text :slip_url
      t.integer :installments
      t.datetime :waiting_confirmation_at
      t.datetime :deleted_at
      t.datetime :invalid_payment_at

      t.timestamps
    end
  end
end
