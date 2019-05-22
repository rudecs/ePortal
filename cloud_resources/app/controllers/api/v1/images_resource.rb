class API::V1::ImagesResource < API::V1
  # helpers API::V1::Helpers

  resource :images, desc: 'Управление образами' do

    helpers do
      def search_params
        declared_params[:search]
      end
    end

    desc 'Поиск доступных образов'
    params do
      optional :search, type: Hash, default: {} do
        optional :location_id, type: Integer
      end
      optional :page, type: Integer, default: 1
      optional :per_page, type: Integer, default: 20
    end
    get jbuilder: 'images/search.json' do
      @images = ImageSearch.new(search_params).results
    end

    # desc 'Просмотр образа'
    # get ':id', jbuilder: 'images/show.json' do
    #   @image = Image.find(params[:id])
    # end
  end
end
