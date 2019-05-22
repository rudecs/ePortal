module Error
  class ServiceRequestError < StandardError

    def initialize(message)
      super(message)
    end
  end
end
