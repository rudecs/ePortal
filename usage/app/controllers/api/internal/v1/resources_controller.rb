# frozen_string_literal: true

module Api
  module Internal
    module V1
      class ResourcesController < BaseController
        def create
          service = Services::Resources::Handle.new(resource_params)
          if service.call
            head :ok
          elsif service.resource.errors.blank? && service.event.errors.count == 1 && (service.event.errors[:base] == ['Only one event of this type can persist per resource'])
            head :ok
          else
            render json: { errors: service.resource.errors.merge!(service.event.errors) }, status: 422
          end
        end

        private

        def resource_params
          params.permit(:resource, :resource_id,
                        :event, :event_started_at, :event_finished_at,
                        :product_id, :client_id, :partner_id, :product_instance_id,
                        :status, :memory, :vcpus, :image_name,
                        :size, :disk_type, :cloud_type, :iops_sec, :bytes_sec)
        end
      end
    end
  end
end
