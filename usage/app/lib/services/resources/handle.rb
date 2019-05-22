# frozen_string_literal: true

module Services
  module Resources
    class Handle
      attr_reader :resource, :event

      def initialize(params)
        @params = params
        $events_log.info "incoming params: #{@params.inspect}"
        transform_params!
        $events_log.info "transformed params: #{@params.inspect}"
        @event = Event.new(event_params)
        @resource = Resource.where(resource_id: @params[:resource_id]).first_or_initialize(resource_params)
      end

      def call
        if @event.create_name? && @resource.kind == 'Machine' && @resource.image_name.nil?
          @resource.errors.add(:image_name, :blank)
          return false
        end

        Resource.transaction do
          handle_resource_attrs
          @resource.save!
          # REVIEW: in case of late destroy event and +rake cron:hourly_report+
          # already created +Payload+ for next billing period
          @resource.payloads.where('period_start > ?', @resource.deleted_at).delete_all if @resource.soft_deleted?

          handle_event_attrs
          @event.save!

          Services::Payloads::Create.new(@resource, @event).call
        end
        $events_log.info 'success'
        $events_log.info "event #{@event.inspect}"
        $events_log.info "resource #{@resource.inspect}"
        true
      rescue
        $events_log.info "Failure. Event errors: #{@event.errors.full_messages} | Resource errors: #{@resource.errors.full_messages}"
        false
      end

      private

      # Assigns resource and corresponding attributes of +resource_parameters+ to event.
      # Also typecasts +Event+ to STI subclass.
      def handle_event_attrs
        @event.resource = @resource
        event_class = [@resource.kind, 'Event'].join('').constantize
        @event = @event.becomes!(event_class) # typecast event for proper validation
        stored_attrs = event_class.stored_attributes[:resource_parameters]
        stored_attrs.each { |key| @event.public_send(key.to_s + '=', @params[key]) } if stored_attrs
      end

      def handle_resource_attrs
        @resource.deleted_at = @event.started_at if @event.delete_name?
        @resource.originally_created_at = @event.finished_at if @event.create_name?
      end

      def resource_params
        result = {
          resource_id: @params[:resource_id],
          kind: @params[:resource].to_s.classify,
          partner_id: @params[:partner_id],
          product_id: @params[:product_id],
          product_instance_id: @params[:product_instance_id],
          client_id: @params[:client_id]
        }
        result[:image_name] = @params[:image_name] if @event.create_name? && result[:kind] == 'Machine'
        result
      end

      def event_params
        {
          name: @params[:event],
          resource_parameters: {},
          started_at: Time.zone.parse(@params[:event_started_at].to_s)&.to_datetime,
          finished_at: Time.zone.parse(@params[:event_finished_at].to_s)&.to_datetime
        }
      end

      def transform_params!
        @params[:event] = 'resize' if %w[start stop].include?(@params[:event])
        if @params[:resource]&.casecmp?('machine') && %w[resize delete].include?(@params[:event]) # REVIEW: delete halted resource
          $events_log.info "halted machine, resource_id: #{@params[:resource_id]}"
          # @params[:resource_parameters][:vcpus], @params[:resource_parameters][:memory] = 0, 0 if @params[:status]&.casecmp?('halted') && machine_resource_parameters_provided?
          @params.merge!(vcpus: 0, memory: 0) if @params[:status]&.casecmp?('halted')
        end
      end

      def machine_resource_parameters_provided?
        @params.dig(:resource_parameters, :vcpus).present? && @params.dig(:resource_parameters, :memory).present?
      end
    end
  end
end
