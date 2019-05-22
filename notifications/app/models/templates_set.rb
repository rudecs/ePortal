class TemplatesSet < ApplicationRecord
  has_many :templates, dependent: :destroy
  # has_many :notifications, through

  accepts_nested_attributes_for :templates, allow_destroy: true

  validates :key_name, presence: true,
                       uniqueness: true,
                       format: { with: /\A\w+\z/ }
end
