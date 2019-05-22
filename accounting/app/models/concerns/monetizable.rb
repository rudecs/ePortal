module Monetizable
  extend ActiveSupport::Concern

  class_methods do
    def monetize(*fields)
      options = fields.extract_options! # not implemented yet

      fields.each do |field|
        field = field.to_s

        # Getter for monetized attribute. TODO: finish it or make Decorator!
        # define_method "readable_#{field}" do |*args|
        #   amount = public_send(field)
        #   currency = public_send(:currency)
        #   # class Money < Struct.new(:value, :currency)
        #   # end
        #   # Money.new(amount&.to_f, currency)
        #   # Struct.new(value: amount&.to_f, currency: currency)
        #   [amount&.to_f, currency]
        # end

        # Setter for monetized attribute
        define_method "#{field}=" do |value|
          # TODO: prescision handling
          # truncate(options[:precision] && options[:precision] >= 0 ? options[:precision] : 4))
          super(value&.to_d&.truncate(4)) if defined?(super)
        end
      end
    end
  end
end

# def rounding_mode=(mode)
#   valid_modes = [
#     BigDecimal::ROUND_UP,
#     BigDecimal::ROUND_DOWN,
#     BigDecimal::ROUND_HALF_UP,
#     BigDecimal::ROUND_HALF_DOWN,
#     BigDecimal::ROUND_HALF_EVEN,
#     BigDecimal::ROUND_CEILING,
#     BigDecimal::ROUND_FLOOR
#   ]
#   raise ArgumentError, "#{mode} is not a valid rounding mode" unless valid_modes.include?(mode)
#   rounding_mode = mode
# end
