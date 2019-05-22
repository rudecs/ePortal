module Services
  module Payu
    class Result
      attr_reader :payment

      def initialize(params, signature_service = Services::Payu::Signature)
        @params = params
        @payment = Payment.unpaid.find(@params[:REFNOEXT]) # REVIEW: not sure REFNOEXT
        @signature_service = signature_service
        @current_time = Time.current.strftime('%Y%m%d%H%M%S')
      end

      def valid?
        begin
          ActiveSupport::SecurityUtils.fixed_length_secure_compare(result_signature, @params[:HASH]) && @payment.currency.casecmp?(@params[:CURRENCY])
        rescue ArgumentError => e
          # ArgumentError, "string length mismatch."
          false
        end
      end

      def check_external_status
        status = @params[:ORDERSTATUS].to_s
        if status.casecmp?('complete')
          true
        elsif status.casecmp?('payment_authorized')
          !@params[:PAYMETHOD]&.casecmp?('Visa/MasterCard/Eurocard')
        elsif status == '-'
          !@params[:PAYMETHOD]&.casecmp?('EUROSET_SVYAZNOI')
        elsif status.casecmp?('test')
          true # TODO: !Rails.env.production?
        else
          false
        end
      end

      def verify_payment
        save_status
        save_payment_method
        check_amount
      end

      def response
        "<epayment>#{@current_time}|#{@signature_service.new(ipn_signature_source).call}</epayment>"
      end

      private

      # handle this with paid? + status?
      # REVERSED  платёж отменен (отменена блокировка денежных средств на карте)
      # REFUND сумма платежа возвращена
      def save_status
        @payment.update_column :status, @params[:ORDERSTATUS] unless @payment.paid?
      end

      def save_payment_method
        @payment.update_column :payment_method, @params[:PAYMETHOD]
      end

      # TODO: figure out received_amount
      def check_amount
        # REVIEW: IPN_TOTALGENERAL = Общая сумма сделки, включая НДС и стоимость доставки, с точкой (.) в качестве десятичного разделителя
        # sum?? IPN_TOTAL[] Промежуточный итог в строке заказа (включая НДС) с точкой (.) в качестве десятичного разделителя
        # + IPN_SHIPPING, IPN_COMMISSION
        received_amount = @params[:IPN_TOTALGENERAL].to_f # TODO: change!!!
        @payment.update_column :amount_cents, (received_amount * 100).to_i unless received_amount == @payment.amount
      end

      def result_signature
        @signature_service.new(@params.except(:HASH)).call
      end

      def ipn_signature_source
        {
          ipn_pid: @params[:IPN_PID][0],
          ipn_pname: @params[:IPN_PNAME][0],
          ipn_date: @params[:IPN_DATE],
          current_time: @current_time
        }
      end
    end
  end
end
