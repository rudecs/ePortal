class RobokassaController < ApplicationController
  def result
    service = Services::Robokassa::Result.new(params)
    if service.valid?
      service.verify_payment
      service.payment.paid!
      render text: service.response
    else
      head :bad_request
    end
  end

  # REVIEW: handle it on frontend or use decorative methods to send notifications
  def success
    # Gem?
    # Services::Notifications::Push.new().send_to current_user

    render json: { message: format('Ваш платёж на сумму %.2f руб успешно принят.', params['OutSum']) }
  end

  def fail
    render json: { message: 'К сожалению, не удалось выполнить оплату. Пожалуйста, попробуйте еще раз.' }
  end
end
