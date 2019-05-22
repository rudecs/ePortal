# frozen_string_literal: true

module Api
  class ServiceStatusController < ApplicationController
    def ping
      # REVIEW: sending 200 status code means that app is ok and runing
      # or there are some steps to check app's health and resturn 500 status code?
      head :ok
    end
  end
end
