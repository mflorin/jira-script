require 'typhoeus'

class RequestQueue

  def initialize
    @hydra = Typhoeus::Hydra.new
  end

  def add(request)
    url = [request.config[:host], request.config[:api_path], request.config[:resource]].join('/')
    req = Typhoeus::Request.new(
        url,
        method: :post,
        userpwd: "#{request.config[:user]}:#{request.config[:password]}",
        body: request.to_json,
        headers: { "Content-Type" => "application/json" }
    )

    @hydra.queue(req)
  end

  def run
    # @hydra.run
  end
end