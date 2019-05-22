# frozen_string_literal: true

class User < ClientsDbBase
  def readonly?
    !Rails.env.test?
  end
end
