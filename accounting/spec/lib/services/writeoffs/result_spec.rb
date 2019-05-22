# frozen_string_literal: true

require 'rails_helper'

describe Services::Writeoffs::Result do
  let!(:writeoff) { create(:unpaid_writeoff) }
  let(:client) { writeoff.client }
  let(:service) { described_class.new(writeoff, nil) }

  describe '#call' do
    subject { service.call }

    before do
      service.instance_variable_set(:@writeoff, writeoff)
    end

    context 'when unpaid writeoff' do
      it 'should retrieve prices' do
        expect(service).to receive(:prices_before_and_after_discount)
        subject
      end

      it 'should change writeoff' do
        allow(service).to receive(:prices_before_and_after_discount)#.and_return

        expect(writeoff).to receive(:tap)
        subject
      end

      it 'should use transaction' do
        allow(service).to receive(:prices_before_and_after_discount).and_return [2, 2]

        expect(Writeoff).to receive(:transaction)
        subject
      end

      context 'when save passed' do
        before do
          allow(writeoff).to receive(:save!).and_return true
        end

        it 'should save billing data' do
          expect(ProductInstanceState).to receive(:create!)
          subject
        end

        it 'should return something' do
          allow(ProductInstanceState).to receive(:create!)

          expect(subject).to be_truthy
        end

        it 'should save writeoff' do
          expect(writeoff).to receive(:save!)
          subject
        end

        it 'should mark writeoff as paid' do
          expect(writeoff).to receive(:paid!)
          subject
        end
      end

      context 'when save failed' do
        before do
          allow(writeoff).to receive(:save!).and_raise
        end

        it 'should return false' do
          expect(subject).to be_falsey
        end

        it 'should not save billing data' do
          expect(ProductInstanceState).not_to receive(:create!)
          subject
        end

        it 'should not mark writeoff as paid' do
          expect(writeoff).not_to receive(:paid!)
          subject
        end
      end
    end

    context 'when paid writeoff' do
      let(:writeoff) { create(:paid_writeoff) }

      it { is_expected.to be_truthy }
    end
  end

  describe '#price_before_discount' do
    let(:charges) { described_class::PARAMS.dup } # TODO: change
    subject { service.send(:price_before_discount) }

    before do
      service.instance_variable_set(:@writeoff, writeoff)
      service.instance_variable_set(:@charges, charges)
    end

    it 'should sum charges' do
      expect(charges).to receive(:sum)
      subject
    end

    context 'when data is missing completely' do
      let(:charges) { nil }

      it 'should raise NoMethodError error' do
        expect { subject }.to raise_error NoMethodError
      end
    end

    context 'when billing_data is missing' do
      let(:charges) { [{ billing_data: nil }] }

      it 'should raise billing_data is missing error' do
        expect { subject }.to raise_error(RuntimeError, 'billing_data is missing')
      end
    end

    context 'when currencies do not match' do
      let(:charges) do
        [
          {
            'billing_data' => {
              'cpu' => {
                'currency' => 'usd'
              }
            }
          }
        ]
      end

      it 'should raise billing_data is missing error' do
        expect { subject }.to raise_error(RuntimeError, 'invalid currency')
      end
    end

    context 'when data present and currency matches' do
      it { is_expected.to be_truthy }
    end
  end

  describe '#prices_before_and_after_discount' do
    subject { service.send(:prices_before_and_after_discount) }

    context 'when client has discount package' do
      before do
        allow(client).to receive(:discountable?).and_return true
      end

      it 'should apply discount' do
        expect(service).to receive(:apply_discount)
        subject
      end
    end

    context 'when client has no discount' do
      let(:price) { 1_000 }
      before do
        allow(client).to receive(:discountable?).and_return false
      end

      it 'should calculate price without discount' do
        expect(service).to receive(:price_before_discount)
        subject
      end

      it 'should return array of two eq prices' do
        allow(service).to receive(:price_before_discount).and_return price
        expect(subject).to eq [price, price]
      end
    end
  end

  # way too big original method. Needs refactoring
  describe '#apply_discount' do
    let(:charges) { described_class::PARAMS.dup } # TODO: change
    let!(:discount_set) { create(:discount_set) }
    subject { service.send(:apply_discount) }

    context 'when discount_sets present in discount_package' do
      before do
        service.instance_variable_set(:@charges, charges)
        allow(client).to receive_message_chain(:discount_package, :discount_sets, :includes).and_return([discount_set])
      end

      it 'should collect discounts' do
        # expect(discount_sets).to receive(:each_with_object)
        # subject
      end

      it 'should sum charges by billing keys' do
        # expect(charges).to receive(:sum)
        # subject
      end

      # or more compicated context
      it 'should sum billing units and apply discount' do
      end

      # temp test. kinda useless. calculated manually
      it 'should calculate two prices' do
        expect(subject).to eq([720.00019, 688.000171])
      end
    end

    context 'when discount_sets absent' do
      before do
        allow(client).to receive_message_chain(:discount_package, :discount_sets, :includes).and_return nil
      end

      it 'should calculate prices withot discounts' do
        expect(service).to receive(:price_before_discount)
        subject
      end
    end
  end
end
