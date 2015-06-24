class Donator < ActiveRecord::Base
  belongs_to :user

  validates :plan_code, :fullname, :email, :cpf, :customer_code, :birthdate,
    :phone_area_code, :phone_number, :zipcode, :uf, :street, :street_number,
    :street_complement, :district, :city, presence: true
end
