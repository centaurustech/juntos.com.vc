class Donator < ActiveRecord::Base
  belongs_to :user

  validates :plan_code, :fullname, :email, :cpf, :birthdate,
    :phone_area_code, :phone_number, :zipcode, :uf, :street, :street_number,
    :district, :city, presence: true
end
