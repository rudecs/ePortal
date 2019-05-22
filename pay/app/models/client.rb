# frozen_string_literal: true

class Client < ClientsDbBase
  def readonly?
    !Rails.env.test?
  end
end
