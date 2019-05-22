class API::V1::PortsResource < API::V1

  resource :ports, desc: 'Управление портами' do

    helpers do
      def create_params
        declared_params[:port].merge({
          partner_id: 1,
        })
      end
    end

    desc 'Просмотр списка портов'
    params do
      optional :search, type: Hash, default: {} do
        optional :client_id,  type: Integer
        optional :client_ids, type: Array[Integer]

        optional :machine_id,  type: Integer
        optional :machine_ids, type: Array[Integer]

        optional :cloud_space_id,  type: Integer
        optional :cloud_space_ids, type: Array[Integer]

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
    get jbuilder: 'ports/search.json' do
      @ports = ::PortSearch.new(search_params).results
    end

    desc 'Создать порт'
    params do
      requires :port, type: Hash, default: {} do
        requires :cloud_space_id, type: Integer
        requires :machine_id, type: Integer
        requires :cloud_protocol, type: String, values: ::Port::PROTOCOLS#, default: 'tcp'
        requires :cloud_local_port, type: Integer
        requires :cloud_public_port, type: Integer
        optional :client_id, type: Integer
        optional :product_id, type: Integer
        optional :product_instance_id, type: Integer
      end
      optional :page, type: Integer, default: 1
      optional :per_page, type: Integer, default: 20
    end
    post jbuilder: 'ports/show.json' do
      @port = ::Port.create!(create_params)
    end

    desc 'Изменить порт'
    params do
      requires :port, type: Hash, default: {} do
        optional :cloud_protocol, type: String, values: ::Port::PROTOCOLS#, default: 'tcp'
        optional :cloud_local_port, type: Integer
        optional :cloud_public_port, type: Integer
        at_least_one_of :cloud_protocol, :cloud_local_port, :cloud_public_port
      end
    end
    put ':id', jbuilder: 'ports/show.json' do
      @port = ::Port.find(params[:id])
      @port.update(declared_params[:port])
    end

    desc 'Удалить порт'
    params do
    end
    delete ':id', jbuilder: 'ports/show.json' do
      @port = ::Port.find(params[:id])
      @port.delete
    end


  end
end
