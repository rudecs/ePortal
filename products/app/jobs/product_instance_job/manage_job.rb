class ProductInstanceJob::ManageJob < ApplicationJob
  def perform
    ProductInstanceJob.where(state: 'new').find_each do |pij|
      begin
        pij.process
      rescue Exception => e
        pij.product_instance.update_attributes({
          error_messages: e.message,
        })
      end
    end
  end
end
