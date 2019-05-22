module API
  module Internal
    class V1 < Grape::API
      @@Boolean = Virtus::Attribute::Boolean

      format :json
      formatter :json, Grape::Formatter::Jbuilder
      content_type :json, 'application/json'

      before do
        env['api.tilt.root'] = 'app/views/api/internal/v1'
      end

      def self.inherited(subclass)
        super

        helpers do
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

      mount V1::NotificationsRequestsResource
      mount V1::TemplatesSetsResource
    end
  end
end
