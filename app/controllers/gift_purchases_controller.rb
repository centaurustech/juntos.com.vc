class GiftPurchasesController < ApplicationController
  before_action :authenticate_user!
  after_filter :verify_authorized
  after_filter :verify_policy_scoped, only: %i(index)

  def index
    authorize(GiftPurchase)
    @gift_purchases = policy_scope(GiftPurchase)
  end

  def show
    @purchase = GiftPurchase.find(params[:id])
    authorize(@purchase)
  end

  def new
    @cards = current_user.juntos_gift_cards.not_bought
    @purchase = GiftPurchase.new(user: current_user, value: @cards.sum(:value))
    authorize(@purchase)
  end

  def get_moip_token
    gift = GiftPurchase.find(params[:id])
    ::MoipTransparente::Config.test = CatarseSettings[:moip_test] == 'true'
    ::MoipTransparente::Config.access_token = CatarseSettings[:moip_token]
    ::MoipTransparente::Config.access_key = CatarseSettings[:moip_key]

    @moip = ::MoipTransparente::Checkout.new

    invoice = {
      razao: "Cartão presente juntos.com.vc",
      id: gift.key,
      total: gift.value.to_s,
      acrescimo: '0.00',
      desconto: '0.00',
      cliente: {
        id: gift.user_id,
        nome: gift.payer_name,
        email: gift.payer_email,
        logradouro: "#{gift.address_street}, #{gift.address_number}",
        complemento: gift.address_complement,
        bairro: gift.address_neighbourhood,
        cidade: gift.address_city,
        uf: gift.address_state,
        cep: gift.address_zip_code,
        telefone: gift.address_phone_number
      }
    }

    moip_response = @moip.get_token(invoice)
    gift.update_column :payment_token, moip_response[:token] if moip_response && moip_response[:token]

    render json: {
      get_token_response: moip_response,
      moip: @moip,
      widget_tag: {
        tag_id: 'MoipWidget',
        token: moip_response[:token],
        callback_success: 'checkoutSuccessful',
        callback_error: 'checkoutFailure'
      }
    }
  end

  def create
    purchase = current_user.gift_purchases.new(permitted_params)
    cards = current_user.juntos_gift_cards.not_bought
    purchase.value = cards.sum(:value)
    purchase.juntos_gift_cards = cards
    purchase.state = 'pending'
    authorize(purchase)
    purchase.save
    cards.each do |gift|
      GiftPurchaseMailer.new_purchase(gift).deliver
      gift.project.contributions.create()
    end
    redirect_to gift_purchases_path
  end

  def checkout
    pagador = {
      nome: "Luiz Inácio Lula da Silva",
      login_moip: "lula",
      email: "presidente@planalto.gov.br",
      tel_cel: "(61)9999-9999",
      apelido: "Lula",
      identidade: "111.111.111-11",
      logradouro: "Praça dos Três Poderes",
      numero: "0",
      complemento: "Palácio do Planalto",
      bairro: "Zona Cívico-Administrativa",
      cidade: "Brasília",
      estado: "DF",
      pais: "BRA",
      cep: "70100-000",
      tel_fixo: "(61)3211-1221"
    }

    billet = {
      valor: "8.90",
      id_proprio: id,
      forma: "BoletoBancario",
      pagador: pagador,
      razao: "Pagamento"
    }

    credit = {
      valor: "8.90",
      id_proprio: id,
      forma: "CartaoCredito",
      instituicao: "AmericanExpress",
      numero: "345678901234564",
      expiracao: "08/11",
      codigo_seguranca: "1234",
      nome: "João Silva",
      identidade: "134.277.017.00",
      telefone: "(21)9208-0547",
      data_nascimento: "25/10/1980",
      parcelas: "2",
      recebimento: 'AVista',
      pagador: pagador,
      razao: 'Pagamento'
    }
    response = MoIP::Client.checkout(boleto)
    redirect_to MoIP::Client.moip_page(response["Token"])
  end

  def redeem
    card = JuntosGiftCard.find_by(code: params[:id], used: false)
    if card
      session[:gift_card_id] = card.id
      redirect_to root_path, notice: t('.card_added')
    else
      redirect_to root_path, notice: t('.card_not_found')
    end
  end

  private

  def permitted_params
    params.require(:gift_purchase).permit(:payer_name, :payer_email,
                                          :payer_document, :address_street,
                                          :address_number, :address_complement,
                                          :address_neighbourhood,
                                          :address_zip_code, :address_city,
                                          :address_state, :address_phone_number,
                                          :country_id)
  end
end
