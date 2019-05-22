# frozen_string_literal: true

module Services
  module Users
    class Registration
      attr_reader :user, :client, :session, :token, :invitation # , :role, :profile
      REDEEMING_AMOUNT = 500

      def initialize(params, token)
        @token = token
        @params = params
        @user = User.new(@params[:user]) # make email hidden field and pass along with link
        @invitation = @token.present? ? Invitation.external.actual.pending.find_by(email: @user.email, token: @token) : nil # find_by_token(@token)

        if @invitation.present?
          # @user.email = @invitation.email # only in case of find_by_token(@token)
          @user.email_confirmed_at = Time.current # .now or .touch later?
          @client = @invitation.client # for view only
        else
          @client = Client.new(@params[:client])
        end

        @session = Session.new
        # @profile = Profile.new
        # @role = Role.new # not sure about this
      end

      def register
        # gather and assign invites to user? they'll become internal and 404 page will be returned
        other_invitations = Invitation.external.actual.pending.where(email: @user.email)
        ActiveRecord::Base.transaction do
          @user.save!

          @session.user = @user
          @session.save!

          if @invitation.present?
            # @role = @invitation.role # if needed in view
            @invitation.receiver = @user
            raise 'unable to perform transition' unless @invitation.accepted!
          else
            @client.save!
            role = Role.create_admin_role(@client)
            Profile.create!(user: @user, role: role)
          end

          other_invitations.update_all(receiver_id: @user.id)
        end
      rescue
        false
      end

      def token_but_blank_invitation?
        @token.present? && @invitation.blank?
      end

      # use after registration!
      # delivery is not guaranteed!
      def add_bonuses
        return if @invitation.present?
        return unless @client.currency&.casecmp?('rub')

        request_path = '/api/internal/v1/payments.json'
        request_params = {
          payment: {
            puid: @client.id,
            source: 'new_registration',
            client_id: @client.id,
            amount: REDEEMING_AMOUNT,
            currency: @client.currency,
          },
        }

        if Rails.env == 'development'
          puts '================================'
          puts 'Services::Users::Registration#add_bonuses'
          puts request_path
          puts JSON.pretty_generate(request_params)
          puts '================================'
          return
        end

        service = Diplomat::Service.get('accounting')
        url = "http://#{service.Address}:#{service.ServicePort}/"

        conn = Faraday.new(url: url) do |faraday|
          faraday.response :logger, ::Logger.new(STDOUT), bodies: true
          faraday.adapter  Faraday.default_adapter
          faraday.headers['Content-Type'] = 'application/json'
        end

        res = conn.post(request_path) do |req|
          req.body = request_params.to_json
        end
      end

    end
  end
end
