# frozen_string_literal: true

module Api
  module V1
    class UsagesController < BaseController
      def index
        search = ResourcesSearch.new(total_params)

        sort_by = sort_by_options(search.options[:sort_by])
        hourly_group = search.options[:hourly].present?

        unless hourly_group
          start_at = I18n.l search.options[:from_to].first
          end_at = I18n.l search.options[:from_to].last
        end

        @resources = search.results.group_by do |r|
          fields = {}
          if hourly_group
            fields[:start_at] = I18n.l r.period_start.in_time_zone
            fields[:end_at] = I18n.l r.period_end.in_time_zone
          else
            fields[:start_at] = start_at
            fields[:end_at] = end_at
          end
          sort_by.each { |key| fields[key] = r.public_send(key) }
          fields
        end
      end

      def speed
        search = ResourcesSearch.new(speed_params)
        sort_by = sort_by_options(search.options[:sort_by])
        @resources = search.results.group_by do |r|
          fields = {}
          sort_by.each { |key| fields[key] = r.public_send(key) }
          fields
        end
      end

      private

      def speed_params
        prms = params.slice(:speed_at, :sort_key, :product_ids, :client_ids, :partner_ids, :product_instance_ids, :resource_ids)
        speed = Time.zone.parse(prms[:speed_at].to_s)
        raise ActionController::ParameterMissing.new(message: 'speed_at param is invalid') unless speed && speed < Time.current
        prms[:speed] = speed
        sort_key_inclusion(prms)
        prms
      end

      def total_params
        prms = params.slice(:from, :to, :sort_key, :hourly, :product_ids, :client_ids, :partner_ids, :product_instance_ids, :resource_ids)
        from = Time.zone.parse(prms[:from].to_s)&.to_datetime&.beginning_of_hour
        to = Time.zone.parse(prms[:to].to_s)&.to_datetime
        raise ActionController::ParameterMissing.new(message: 'from_to param is invalid') unless from && to && to < Time.current.end_of_hour

        prms[:from_to] = [from, to&.end_of_hour]
        sort_key_inclusion(prms)
        prms
      end

      # Extracts +:sort_key+ from request parameters if invalid
      def sort_key_inclusion(prms)
        prms.extract!(:sort_key) unless %w[resource_id partner_id]&.include?(prms[:sort_key]) # default by kind, client_id, product_instance_id, product_id
      end

      # Retunrs options without table names and removes 'kind' from them
      # cause records will be grouped by kind later
      def sort_by_options(opts)
        opts.map { |by| by.split('.').second }.reject { |by| by == 'kind' }
      end
    end
  end
end
