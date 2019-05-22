class API::V1::SnapshotsResource < API::V1

  resource :snapshots, desc: 'Управление снапшотами' do

    helpers do
      def create_params
        declared_params[:snapshot].merge({
          partner_id: 1,
        })
      end
    end

    desc 'Просмотр списка снапшотов'
    params do
      optional :search, type: Hash, default: {} do
        optional :client_id,  type: Integer
        optional :client_ids, type: Array[Integer]

        optional :machine_id,  type: Integer
        optional :machine_ids, type: Array[Integer]

        optional :partner_id,  type: Integer
        optional :partner_ids, type: Array[Integer]

        optional :product_id,  type: Integer
        optional :product_ids, type: Array[Integer]

        optional :product_instance_id,  type: Integer
        optional :product_instance_ids, type: Array[Integer]

        optional :state,  type: String,        default: 'active', values: ResourcesStates::STATES
        optional :states, type: Array[String], default: 'active', values: ResourcesStates::STATES
      end
      optional :page, type: Integer, default: 1
      optional :per_page, type: Integer, default: 20
    end
    get jbuilder: 'snapshots/search.json' do
      @snapshots = ::SnapshotSearch.new(search_params).results
    end

    desc 'Восстановления виртуалки из снапшота'
    post '/:id/rollback', jbuilder: 'snapshots/show.json' do
      @snapshot = ::Snapshot.find(params[:id])
      @snapshot.rollback
    end

  end

end
