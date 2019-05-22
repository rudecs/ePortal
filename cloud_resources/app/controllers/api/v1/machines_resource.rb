class API::V1::MachinesResource < API::V1

  resource :machines, desc: 'Управление виртуалками' do

    helpers do
    end

    desc 'Просмотр списка виртуалок'
    params do
      optional :search, type: Hash, default: {} do
        optional :client_id,  type: Integer
        optional :client_ids, type: Array[Integer]

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
    get jbuilder: 'machines/search.json' do
      @machines = MachineSearch.new(search_params).results
    end


    desc 'Просмотр информации о витуалке (в том числе из гига)'
    get ':id', jbuilder: 'machines/show.json' do
      @machine = Machine.find(params[:id])
    end

    desc 'Запуск виртуалки'
    post ':id/start', jbuilder: 'machines/show.json' do
      @machine = Machine.find(params[:id])
      @machine.start
    end

    desc 'Остановка виртуалки'
    post ':id/stop', jbuilder: 'machines/show.json' do
      @machine = Machine.find(params[:id])
      @machine.stop
    end

    desc 'Приостановка виртуалки'
    post ':id/pause', jbuilder: 'machines/show.json' do
      @machine = Machine.find(params[:id])
      @machine.pause
    end

    desc 'Ресет виртуалки'
    post ':id/reset', jbuilder: 'machines/show.json' do
      @machine = Machine.find(params[:id])
      @machine.reset
    end

    desc 'Получить ссылку на консоль'
    get ':id/console', jbuilder: 'machines/console.json' do
      @machine = Machine.find(params[:id])
      @console_url = @machine.get_console_url
      ssh = @machine.fetch.accounts.first
      @ssh_login = ssh['login']
      @ssh_password = ssh['password']
    end

    # desc 'Ребут виртуалки'
    # post ':id/reboot', jbuilder: 'machines/show.json' do
    #   @machine = Machine.find(params[:id])
    # end

  end
end
