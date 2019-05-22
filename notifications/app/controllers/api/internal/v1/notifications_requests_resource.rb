# frozen_string_literal: true

module API
  module Internal
    class V1::NotificationsRequestsResource < V1 # V1
      # helpers API::V1::Helpers

      resource :notifications_requests, desc: 'Запрос на уведомление' do

        helpers do
          def notifications_request_params
            declared_params[:notifications_request]
          end
        end

        desc 'Создать запрос на уведомление'
        params do
          requires :notifications_request, type: Hash do
            optional :content, type: String # text
            optional :key_name, type: String # , values: -> { TemplatesSet.all.map(&:key_name) } pluck
            mutually_exclusive :key_name, :content
            optional :delivery_method, type: String
            all_or_none_of :content, :delivery_method # not sure
            # TODO: at least one of client_ids or user_ids
            optional :user_ids, type: Array[Integer]
            optional :client_ids, type: Array[Integer]
            optional :emails, type: Array[String]
            optional :phones, type: Array[String]
            exactly_one_of :client_ids, :user_ids, :emails, :phones
            optional :category, type: String
            mutually_exclusive :category, :user_ids, :emails, :phones
            # mutually_exclusive :category, :user_ids
            optional :provided_data, type: Hash
            # optional :notify_roles, type: Array[String] # , values: -> { CONFIG.roles }
            # mutually_exclusive :notify_roles, :user_ids
          end
        end
        post jbuilder: 'notifications_requests/show.json' do
          TemplatesSet.find_by!(key_name: params[:notifications_request][:key_name]) if params[:notifications_request][:key_name].present? # remove in case of values
          @notifications_request = NotificationsRequest.new(notifications_request_params)
          if @notifications_request.save
            NotificationsRequest::ProcessJob.perform_later(@notifications_request.id)
          else
            $create_notifications_request.info "failed with params #{notifications_request_params}"
            error_422! @notifications_request.errors
          end
        end
      end
    end
  end
end
