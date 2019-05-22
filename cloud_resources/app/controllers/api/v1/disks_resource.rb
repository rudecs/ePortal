class API::V1::DisksResource < API::V1

  resource :disks, desc: 'Управление дисками' do

    helpers do
      def create_params
        declared_params[:disk].merge({ partner_id: 1, cloud_type: 'D' })
      end
    end

    desc 'Просмотр списка дисков'
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
    get jbuilder: 'disks/search.json' do
      @disks = ::DiskSearch.new(search_params).results
    end

    desc 'Просмотр информации о диске'
    get ':id', jbuilder: 'disks/show.json' do
      @disk = Disk.find(params[:id])
    end

    desc 'Создать диск'
    params do
      requires :disk, type: Hash, default: {} do
        requires :machine_id, type: Integer
        requires :size, type: Integer
        requires :client_id, type: Integer
        requires :product_id, type: Integer
        requires :product_instance_id, type: Integer
      end
    end
    post jbuilder: 'disks/show.json' do
      @disk = ::Disk.create!(create_params)
    end

    desc 'Изменить размер диска'
    params do
      requires :disk, type: Hash, default: {} do
        requires :size, type: Integer
      end
    end
    put ':id', jbuilder: 'disks/show.json' do
      @disk = ::Disk.data_type.find(params[:id])
      # @disk.update(declared_params[:disk])
      error_422! 'invalid disk size' if declared_params[:disk][:size] <= @disk.size
      @disk.resize(declared_params[:disk][:size])
    end

    desc 'Удалить диск'
    params do
    end
    delete ':id', jbuilder: 'disks/show.json' do
      @disk = ::Disk.data_type.find(params[:id])
      @disk.delete
    end

  end
end
