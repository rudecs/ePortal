class API::V1::CloudSpacesResource < API::V1

  resource :cloud_spaces, desc: 'Управление клауд спейсами' do

    helpers do
    end

    desc 'Просмотр списка клауд спейсов'
    params do
      optional :search, type: Hash, default: {} do
        optional :client_id,  type: Integer
        optional :client_ids, type: Array[Integer]

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
    get jbuilder: 'cloud_spaces/search.json' do
      @cloud_spaces = CloudSpaceSearch.new(search_params).results
    end


    desc 'Просмотр информации о клауд спейсе (в том числе из гига)'
    get ':id', jbuilder: 'cloud_spaces/show.json' do
      @cloud_space = CloudSpace.find(params[:id])
    end

  end
end
