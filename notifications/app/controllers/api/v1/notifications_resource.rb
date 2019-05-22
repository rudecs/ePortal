# frozen_string_literal: true

module API
  class V1::NotificationsResource < API::V1
    # helpers API::V1::Helpers

    resource :notifications, desc: 'Уведомления' do

      helpers do
        def search_params
          declared_params[:search].merge(
            with_templates: true,
            delivery_methods: ['email', 'onsite']
          )
        end
      end

      desc 'Список уведомлений пользователя'
      params do
        optional :search, type: Hash, default: {} do
          optional :unread, type: Boolean, default: false
        end
        optional :page, type: Integer, default: 1
        optional :per_page, type: Integer, default: 20
      end
      get jbuilder: 'notifications/search.json' do
        authenticate!
        # REVIEW: use delivered scope?
        @notifications = NotificationsSearch.new(search_params.merge(user_id: current_user['id']))
                                            .results
                                            .order(created_at: :desc)
                                            .page(params[:page])
                                            .per_page(params[:per_page])
      end

      desc 'Прочтение уведомлений'
      params do
        requires :ids, type: Array[Integer], allow_blank: false
      end
      put '/mark_as_read' do
        authenticate!
        Notification.where(user_id: current_user['id'], id: declared_params[:ids])
                    .unread
                    .update_all(read_at: Time.current)
        {}
      end
    end
  end
end
