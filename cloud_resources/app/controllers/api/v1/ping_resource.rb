class API::V1::PingResource < API::V1
  resource :ping, desc: 'Ping' do
    get do
      {}
    end
  end
end
