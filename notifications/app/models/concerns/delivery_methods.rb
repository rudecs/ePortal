# frozen_string_literal: true

module DeliveryMethods
  extend ActiveSupport::Concern

  included do
    # onsite vs push order
    enum delivery_method: { email: 0, sms: 1, onsite: 2, push: 3 } # , _suffix: true
  end
end
