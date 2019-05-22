# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MachineEvent, type: :model do
  # TODO: finish same tests for similar methods
  describe '.chargable_memory' do
    let(:events_resource_parameters) do
      [{ 'memory' => 1 }, { 'memory' => 2 }]
    end
    it { expect(described_class.chargable_memory(events_resource_parameters)).to eq 2 }
  end
end
