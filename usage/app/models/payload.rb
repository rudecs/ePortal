# frozen_string_literal: true

class Payload < ApplicationRecord
  self.table_name = 'usages'

  belongs_to :resource

  validates :resource, :period_start, :period_end, presence: true
  validates :period_start, uniqueness: { scope: %i[resource_id period_end] }, if: :uniq_fields_present?
  # 1.hour billing period
  # chargable?

  private

  # Validations
  def uniq_fields_present?
    resource_id && period_start && period_end
  end
end
