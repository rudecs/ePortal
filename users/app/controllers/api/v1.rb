class API::V1 < Grape::API
  @@Boolean = Virtus::Attribute::Boolean

  format :json
  formatter :json, Grape::Formatter::Jbuilder
  content_type :json, 'application/json'

  before do
    env['api.tilt.root'] = 'app/views/api/v1'
  end

  def self.inherited(subclass)
    super

    helpers do
      def authenticate!
        error_401! unless session_token.present?
        @current_session = Session.find_by_token(session_token)
        error_401! unless @current_session.present?
        @current_user = @current_session.user
        error_403!(state: ['is not active']) unless @current_user.state == 'active'
        error_403!(email: ['is not confirmed']) unless @current_user.email_confirmed_at.present?

        if @current_user.is_enabled_2fa
          unless @current_session.sms_token_confirmed_at.present?
            error_403!(sms_token: ['is not confirmed'])
          end
        end

        @current_roles = Role.joins(profiles: :user).where(users: {id: @current_user.id})
        @current_clients = Client.joins(:roles).where(roles: {id: @current_roles.pluck(:id)})
      end

      def current_session
        @current_session
      end

      def current_user
        @current_user
      end

      def current_clients
        @current_clients
      end

      def current_roles
        @current_roles
      end

      def declared_params
        declared(params, include_missing: false).merge({})
      end

      def error_400!()
        resp = {
          :code => 400,
          :message => "bad_request"
        }

        error!(resp, 400)
      end

      def error_401!()
        resp = {
          :code => 401,
          :message => 'unauthorized',
          :errors => {}
        }

        error!(resp, 401)
      end

      def error_403!(errors = {})
        content = {
          :code => 403,
          :message => 'access_denied',
          :errors => errors
        }
        error!(content, 403)
      end

      def error_404!()
        resp = {
          :code => 404,
          :message => 'not_found',
          :errors => []
        }

        error!(resp, 404)
      end

      def error_422!(errors = {})
        resp = {
          :code => 422,
          :message => 'unprocessable_entity',
          :errors => errors
        }

        error!(resp, 422)
      end

      def error_500!(errors = {})
        resp = {
          :code => 500,
          :message => 'internal_server_error',
          :errors => errors
        }

        error!(resp, 500)
      end

      def session_token
        token = request.headers['X-Session-Token']
        token = params['session_token'] unless token.present?
        token
      end
    end

    subclass.instance_eval do
      rescue_from ActiveRecord::RecordNotFound do |e|
        content = { :code => 404, :message => 'not_found', errors: {} }
        content.merge!(:backtrace => e.backtrace) if !Rails.env.production?

        Rack::Response.new(
          [content.to_json],

          404,
          { 'Content-Type' => 'application/json' }
        )
      end
    end

  end

  mount API::V1::ClientsResource
  mount API::V1::InvitationsResource
  mount API::V1::PasswordsResource
  mount API::V1::ProfileResource
  mount API::V1::RegisterResource
  mount API::V1::SessionResource
  mount API::V1::UsersResource
end
