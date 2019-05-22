# frozen_string_literal: true

class PaymentsSearch < Searchlight::Search
  def base_query
    Payment
  end

  def search_client_id
    query.where(client_id: client_id)
  end

  def search_user_id
    query.where(user_id: user_id)
  end

  def search_only_money
    if only_money
      query.where(source: 'payment')
    else
      query.where.not(source: 'payment')
    end
  end
end
