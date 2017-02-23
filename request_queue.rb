require 'typhoeus'

class RequestQueue

  def initialize
    @hydra = Typhoeus::Hydra.new
  end

  def add(request)
    url = [request.config[:host], request.config[:api_path], request.config[:resource]].join('/')
    req = Typhoeus::Request.new(
        url,
        ssl_verifypeer: false,
        method: request.config[:request_type],
        userpwd: "#{request.config[:user]}:#{request.config[:password]}",
        body: request.to_json,
        headers: { 'Content-Type' => 'application/json' }
    )

    req.response
    req.run

    #@hydra.queue(req)
  end

  def run
    #p 'running hydra'
    #@hydra.run
  end
end