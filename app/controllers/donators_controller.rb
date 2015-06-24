class DonatorsController < ApplicationController
  layout 'juntos_bootstrap'
  before_action :authenticate_user!, only: %i(create)

  def new
    if user_signed_in?
      default_attrs = {
        user: current_user,
        fullname: current_user.name,
        email: current_user.email,
        birthdate: current_user.birth_date,
        street: current_user.address_street,
        street_number: current_user.address_number,
        street_complement: current_user.address_complement,
        district: current_user.address_neighbourhood,
        zipcode: current_user.address_zip_code.gsub(/[^\d]/, ''),
        city: current_user.address_city
      }
      if current_user.individual?
        default_attrs.merge!(cpf: current_user.cpf.gsub(/[^\d]/, ''))
      end
      @donator = Donator.new(default_attrs)
      @exist_donation = Donator.find_by(user: current_user, status: 'paid') # TODO verificar o status
    else
      @donator = Donator.new
    end
    @projects = Project.successful.order('RANDOM()').limit(4)
  end

  def create
    @donator = Donator.new(permitted_params)
    @donator.user = current_user
    if @donator.save
      @exist_donation = @donator
    end
    @projects = Project.successful.order('RANDOM()').limit(4)
    render :new
  end

  def permitted_params
    params.require(:donator).permit(:plan_code, :fullname, :email, :cpf,
                                    :customer_code, :birthdate,
                                    :phone_area_code, :phone_number, :street,
                                    :street_number, :street_complement,
                                    :district, :zipcode, :city, :uf)
  end
end
