# frozen_string_literal: true

module Services
  module Payloads
    class Create
      attr_reader :resource, :event

      def initialize(resource, event, options = {})
        @options = options
        @resource = resource
        @event = event
        @payload = Payload.where(resource_id: @resource.id, period_start: billing_period.first, period_end: billing_period.last).first_or_initialize
      end

      def call
        @payload.assign_attributes(payload_params)
        @payload.save!
      end

      private

      # Returns billing period from options or based on event's name
      def billing_period
        # TODO: ugly oneliner
        @billing_period ||= @options[:billing_period].presence || period(Event::START_TIME_EVENTS.include?(@event.name) ? @event.started_at : @event.finished_at)
      end

      def period(time)
        [time.beginning_of_hour, time.end_of_hour]
      end

      # Returns hash with chargable values
      def chargable
        event_class = @event.type.constantize
        chargable_hash = {}
        avaliable_fields = event_class.stored_attributes[:resource_parameters]

        if avaliable_fields
          chargable_events_params = chargable_params
          avaliable_fields.each do |key|
            chargable_hash[key] = event_class.public_send(['chargable', key.to_s].join('_'), chargable_events_params)
          end
        end

        chargable_hash
      end

      # Returns array of +resource_parameters+ from events, that heppened during billing period.
      # It also includes last event before current billing period in some cases.
      def chargable_params
        chargable_events = Event.where(resource_id: @resource.id, started_at: billing_period.first..billing_period.last).where.not(name: :create)
                                .or(Event.where(resource_id: @resource.id, finished_at: billing_period.first..billing_period.last).create_name)
                                .order(name: :desc, started_at: :desc)

        # TODO: refactor
        unless @event.create_name? || chargable_events&.last&.create_name? # don't look for previous events in case of create
          if chargable_events.blank? || (chargable_events && chargable_events.last.started_at > billing_period.first) # started_at cause last event name is not "create"
            last_event = @resource.last_event_before(billing_period.first)
            chargable_events += [last_event] if last_event
          end
        end

        chargable_events.map(&:resource_parameters)
      end

      def payload_params
        {
          resource_id: @resource.id,
          chargable: chargable,
          period_start: billing_period.first,
          period_end: billing_period.last
        }
      end
    end
  end
end
