# frozen_string_literal: true

require 'rails_helper'

describe Services::Writeoffs::Create do
  let(:client) { build(:prepaid) }
  let(:service) { described_class.new(Time.current) }

  describe '#call' do
    subject { service.call }

    it 'should generate writeoffs' do
      expect(service).to receive(:generate_writeoffs)
      subject
    end

    context 'when writeoffs present' do
      before do
        allow(service).to receive(:generate_writeoffs).and_return [{}] # .and_return ARRAY of stubbed hash
      end

      # actually nested transaction
      it 'should use transaction' do
        expect(Writeoff).to receive(:transaction)
        subject
      end

      context 'when writeoffs` creation passed' do
        before do
          allow(Writeoff).to receive(:create!)
        end

        it { is_expected.to be true }
      end

      context 'when writeoffs` creation failed' do
        before do
          allow(Writeoff).to receive(:create!).and_raise
        end

        it { is_expected.to be_falsey }
      end
    end

    # actually it is still success
    context 'when no writeoffs were generated' do
      before do
        allow(service).to receive(:generate_writeoffs).and_return []
      end

      it { is_expected.to be true }
    end
  end

  describe '#generate_writeoffs' do
    let(:client_1) { build(:prepaid) }
    let(:client_2) { build(:postpaid) }
    subject { service.send(:generate_writeoffs) }

    before do
      allow(Client).to receive(:includes).with(:writeoffs).and_return [client_1, client_2]
    end

    it 'should handle postpaid and prepaid client' do
      expect(service).to receive(:handle_postpaid).at_least(:once)
      expect(service).to receive(:handle_prepaid).at_least(:once)
      subject
    end
  end

  describe '#handle_prepaid' do
    subject { service.send(:handle_prepaid) }
    # assignment logic?
    # context when force_creating == false
    # it should early return and don't yield
    # context when force_creating == true
    # it should yield block and make recursive call
  end

  describe '#handle_postpaid' do
    subject { service.send(:handle_postpaid) }
    # context prev writeoffs
    #   monthly
    #     deltetion impact?
    # context no writeoffs
    #   deltetion impact?
  end

  describe '#deleted_greater_than_end_date?' do
    let(:soft_deleted) { true }
    subject { service.send(:deleted_greater_than_end_date?, client) }

    before do
      allow(client).to receive(:soft_deleted?).and_return soft_deleted
    end

    context 'when soft deleted' do
      let(:current_time) { Time.current }
      it 'should compare times' do
        allow(client).to receive_message_chain(:deleted_at, :end_of_hour).and_return current_time
        allow(client).to receive(:next_billing_end_date).and_return current_time

        expect(client).to receive_message_chain(:deleted_at, :end_of_hour)
        expect(client).to receive(:next_billing_end_date)

        subject
      end
    end

    context 'when active' do
      let(:soft_deleted) { false }
      it { is_expected.to be true }
    end
  end

  describe '#deletion_impact_absent?' do
    subject { service.send(:deletion_impact_absent?, client) }

    context 'when deleted_at greater or equal than end_date' do
      before do
        allow(service).to receive(:deleted_greater_than_end_date?).and_return true
      end

      it { is_expected.to be true }
    end

    context 'when deleted_at less than end_date' do
      let(:client) { build(:prepaid, deleted_at: 1.minute.ago, next_billing_start_date: Time.current) }
      before do
        allow(service).to receive(:deleted_greater_than_end_date?).and_return false
      end

      it 'should should change next_billing_end_date and return boolean' do
        expect { subject }.to change { client.next_billing_end_date }.to client.deleted_at
        expect(subject).to be_falsey
      end
    end
  end

  describe '#calc_day_of_month!' do
    let(:writeoff_date) { '2018-01-29'.in_time_zone }
    let(:next_end_date) { '2018-01-30'.in_time_zone }
    let(:client) { build(:postpaid, writeoff_interval: 3, writeoff_date: writeoff_date, next_billing_end_date: next_end_date) }
    subject { service.send(:calc_day_of_month!, client) }

    # in this case +writeoff_day+ number can't be greater
    # than number of days in month cause of method
    # +next_month(1)+ applied earlier to client
    context 'when writeoff_day less than next_billing_end_date' do
      it 'should change end_date' do
        expect { subject }.to change { client.next_billing_end_date }.to writeoff_date
      end
    end

    context 'when writeoff_day greater than next_billing_end_date' do
      let(:writeoff_date) { '2018-01-31'.in_time_zone }
      context 'when writeoff_day number less than number of days in month' do
        it 'should change end_date' do
          expect { subject }.to change { client.next_billing_end_date }.to writeoff_date
        end
      end

      context 'when writeoff_day number greater than number of days in month' do
        let(:next_end_date) { '2018-02-27'.in_time_zone }
        it 'should change end_date' do
          expect { subject }.to change { client.next_billing_end_date }.to next_end_date.change(day: Time.days_in_month(next_end_date.month, next_end_date.year))
        end
      end
    end
  end
end
