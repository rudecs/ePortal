class API::V1::LocationsResource < API::V1
  # helpers API::V1::Helpers

  resource :locations, desc: 'Управление локациями' do

    helpers do
    end

    desc 'Поиск доступных локаций'
    params do
      optional :search, type: Hash do
      end
      optional :page, type: Integer, default: 1
      optional :per_page, type: Integer, default: 20
    end
    get jbuilder: 'locations/search.json' do
      @locations = Location.where(state: 'active', deleted_at: nil)
    end

    desc 'Просмотр локации'
    get ':id', jbuilder: 'locations/show.json' do
      @location = Location.find(params[:id])
    end
  end
end
