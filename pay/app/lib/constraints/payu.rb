class Constraints::Payu
  def initialize
    @ips = retrieve_ips
  end

  def matches?(request)
    @ips.include?(request.remote_ip)
  end

  private

  def retrieve_ips
    ['176.223.167.70', '185.68.12.69']
  end
end
