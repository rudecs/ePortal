# frozen_string_literal: true

class ServiceStatusController < ApplicationController
  def ping
    head :ok
  end
end
