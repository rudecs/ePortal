class API::Internal::V1::PlaybooksResource < API::Internal::V1
  resource :playbooks, desc: 'Управление плейбуками' do

    helpers do
      def create_params
        declared_params[:playbook].merge({
          partner_id: 1,
          state: 'pending',
        })
      end

      def free_ids_count_param
        count = params[:count] || 1
        if count > 100
          count = 100
        elsif count < 1
          count = 1
        end
        count
      end
    end

    desc 'Получить свободные айдишники ресурсов для использования в плейбуках'
    params do
      optional :count, type: Integer
    end
    post 'free_ids' do
      ids = free_ids_count_param.times.map do
        ResourceIdSequence.nextval
      end
      {ids: ids}
    end

    desc 'Создать плейбук'
    params do
      requires :playbook, type: Hash do
        optional :user_id, type: Integer
        optional :client_id, type: Integer
        optional :product_id, type: Integer
        # optional :partner_id, type: Integer
        optional :product_instance_id, type: Integer
        optional :product_instance_job_id, type: Integer
        requires :schema, type: Array
      end
    end
    post do
      @playbook = Playbook.create!(create_params)
      ExecutePlaybookJob.perform_later(@playbook.id)

      {playbook: @playbook}
    end

    desc 'Просмотр информации о плейбуке'
    get ':id' do
      @playbook = Playbook.find(params[:id])
      {playbook: @playbook}
    end

  end
end
