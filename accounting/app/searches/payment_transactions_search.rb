# frozen_string_literal: true

class PaymentTransactionsSearch < Searchlight::Search
  def base_query
    PaymentTransaction
  end

  def search_client_ids
    query.where(client_id: client_ids)
  end

  def search_client_id
    query.where(client_id: client_id)
  end

  def search_to
    query.where(created_at: options[:from]..options[:to]) # .. || ...?
  end

  def search_subject_type
    query.where(subject_type: subject_type)
  end

  def search_account_type
    query.where(account_type: account_type)
  end
end
