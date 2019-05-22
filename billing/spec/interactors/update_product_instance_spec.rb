require 'rails_helper'

RSpec.describe UpdateProductInstance, type: :interactor do
  describe '.call' do
    context 'when product_instance not exists' do
      subject(:context) do
        UpdateProductInstance.call(product_instance_id: 111111, code: 'some code', lang: 'js')
      end

      it 'create new product_instance and billing_code_version' do
        expect(subject).to be_a_success
        expect(subject.product_instance.id).to eq 111111
        expect(subject.billing_code_version.code).to eq 'some code'
        expect(subject.billing_code_version.lang).to eq 'js'
        expect(subject.product_instance.current_billing_code_version_id).to eq subject.billing_code_version.id
      end
    end

    context 'when product_instance already exists' do
      let!(:product_instance_exited) { create(:product_instance) }

      subject(:context) do
        UpdateProductInstance.call(product_instance_id: product_instance_exited.id, code: 'some code', lang: 'js')
      end

      it 'update existed product_instance and current_billing_code_version' do
        expect(subject).to be_a_success
        product_instance_exited.reload
        expect(ProductInstance.count).to eq 1
        expect(BillingCodeVersion.count).to eq 2
        expect(product_instance_exited.current_billing_code_version.code).to eq 'some code'
      end
    end
  end
end
