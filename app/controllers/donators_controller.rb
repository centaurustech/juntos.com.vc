class DonatorsController < ApplicationController
  layout 'juntos_bootstrap'
  before_action :authenticate_user!, only: %i(create)
  before_action :set_country_payment_engine, only: %i(new)

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
        zipcode: (current_user.address_zip_code && current_user.address_zip_code.gsub(/[^\d]/, '')),
        city: current_user.address_city,
        key: "user_#{current_user.id}-#{SecureRandom.hex}"
      }
      if current_user.individual?
        default_attrs.merge!(cpf: current_user.cpf.gsub(/[^\d]/, ''))
      end
      @donator = Donator.new(default_attrs)
      @exist_donation = Donator.find_by(user: current_user, status: 'ACTIVE')
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

  def moip_cancel
    donation = Donator.find_by(user: current_user, status: 'ACTIVE')
    if donation
      url = "https://#{Rails.env.production? ? 'api.moip.com.br' : 'sandbox.moip.com.br'}/assinaturas/v1/subscriptions/#{donation.key}/cancel"
      token = Base64.strict_encode64("#{CatarseSettings.get_without_cache(:moip_token)}:#{CatarseSettings.get_without_cache(:moip_key)}")
      header = {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json',
        'Authorization' => "Basic #{token}"
      }
      HTTParty.put(url, headers: header)
      redirect_to new_donator_path, notice: 'Assinatura cancelada'
    else
      redirect_to new_donator_path, alert: ''
    end
  end

  def moip_notification
    if request.headers['HTTP_AUTHORIZATION'] == ENV['MOIP_ASSINATURAS_AUTHORIZATION']
      if params[:event] == 'subscription.created' || params[:event] == 'subscription.updated'
        donator = Donator.find_or_initialize_by(key: permitted_notification_params[:resource][:code])
        donator.customer_code = permitted_notification_params[:resource][:customer][:code]
        donator.status = permitted_notification_params[:resource][:status]
        donator.user_id = donator.key && donator.key.match(/user_(\d+)-.*/)[1]
        donator.save

        render nothing: true, status: 200
      elsif params[:event] == 'subscription.activated'
        render nothing: true, status: 200
      elsif params[:event] == 'subscription.canceled'
        permitted_notification_params[:resource][:code]
        render nothing: true, status: 200
      elsif params[:event] == 'subscription.suspended'
        permitted_notification_params[:resource][:code]
        render nothing: true, status: 200
      elsif
        permitted_notification_params[:resource][:plan][:code]
        permitted_notification_params[:resource][:status]
        permitted_notification_params[:resource][:code]
        permitted_notification_params[:resource][:customer][:code]
        render nothing: true, status: 200
      end
    else
      render nothing: true, status: 404
    end
  end

  def permitted_params
    params.require(:donator).permit(:plan_code, :fullname, :email, :cpf, :customer_code, :birthdate, :phone_area_code, :phone_number, :street, :street_number, :street_complement, :district, :zipcode, :city, :uf, :key, :payment_engine)
  end

  def permitted_notification_params
    params.permit(:event, resource: [:status, :code, customer: [:code], plan: [:code]])
  end
end
