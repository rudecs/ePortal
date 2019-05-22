# frozen_string_literal: true

module Services
  module Notifications
    class Create
      attr_reader :notification_request, :users

      # TODO: handle paginated request-responce. shit.
      # move request + users out of here?
      # handle empty resp.
      def initialize(request, options = {})
        @notification_request = request
        # TODO: handle users without phone?!
        @users =
          if @notification_request.personalized?
            Services::Clients::Request.new(@notification_request).call['users']
          else
            build_users
          end
        @options = options
      end

      def call
        Notification.transaction do
          @notification_request.processed! # REVIEW: pagination
          Notification.create!(params).pluck(:id, :delivery_method) # array
        end
      rescue
        false
      end

      private

      # @users ???? where to get client's data, OR where it's just user-notification
      def params
        keyable = @notification_request.key_name.present?
        # phone + sms case?!
        raise 'keyable without templates' if keyable && templates.blank? # IN CASE OF SOFT FALLBACK
        @users.each_with_object([]) do |user, result|
          # REVIEW: user['locale'] || # CONFIG.fallback_locale ? No need actualy for this
          raw_template = keyable ? select_template(user) : nil
          # REVIEW: sms thing
          raise 'trying to send sms without phone number' if raw_template.nil? && @notification_request.sms? # next if
          notif = {
            notifications_request_id: @notification_request.id,
            user_id: user['id'], # @notification_request.user_id
            # REVIEW: fill_content(@notification_request.content)
            content: raw_template.present? ? fill_content(user, raw_template.content) : @notification_request.content,
            template: raw_template.presence,
            delivery_method: raw_template.present? ? raw_template.delivery_method : @notification_request.delivery_method
          }
          destination!(notif, user)
          result << notif
        end
      end

      def templates
        @templates ||= TemplatesSet.find_by(key_name: @notification_request.key_name)&.templates&.order(delivery_method: :asc)
      end

      # delivery methods ranking
      # def fallback
      #   # REVIEW: soft fallback with templates.first?
      #   # @notification_request.delivery_method
      #   @fallback ||= (templates.where(locale: 'en').first || templates.first) # CONFIG.fallback_locale
      # end

      def select_template(user)
        # raise 'no default template' unless fallback.present? # IN CASE OF HARD FALLBACK
        locale = user['locale']

        # REVIEW: in case of phone confirmation. this lines are very important!
        phone = @notification_request.provided_data['phone']
        user['phone'] = phone if phone.present? && @notification_request.provided_data['phone_confirmation_code'].present?

        tmpls = user['phone'].present? ? templates : templates.where.not(delivery_method: 'sms')
        # raise if tmpls.nil?
        tmpls.find { |t| t.locale == locale && t.delivery_method == @notification_request.delivery_method } ||
          tmpls.find { |t| t.locale == locale } ||
          tmpls.find { |t| t.delivery_method == @notification_request.delivery_method } ||
          tmpls.find { |t| t.locale == 'en' } ||
          tmpls.first # CONFIG.fallback_locale
      end

      def fill_content(user, raw_template, content_manager = Services::Content::Parser)
        content_manager.new(
          OpenStruct.new(user),
          user['client'].present? ? OpenStruct.new(user['client']) : nil,
          raw_template,
          operations: @notification_request.provided_data
        ).call
      end

      def destination!(notif, user)
        notif[:destination] =
          case notif[:delivery_method]
          when 'email' then user['email']
          when 'sms' then user['phone']
          else nil
          end
      end

      def build_users
        field = @notification_request.emails.present? ? 'email' : 'phone'
        data = @notification_request.emails.presence || @notification_request.phones
        # TODO: provided_data[:locale]
        data.each_with_object([]) { |value, users| users << { field => value, 'locale' => @notification_request.provided_data[:locale] }}
      end
    end
  end
end
