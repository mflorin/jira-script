require 'request'
#require 'request_queue'

class Jira

  attr_accessor :config, :request_queue, :request

  def initialize
    self.config = {}
  #  self.request_queue = RequestQueue.new
  end

  def self.run(&block)
    j = Jira.new
    Jira.new.instance_eval(&block)
   # j.request_queue.run
  end

  # config related methods
  def user(u)
    self.config[:user] = u
  end

  def password(p)
    self.config[:password] = p
  end

  def host(h)
    self.config[:host] = h
  end

  def api_path(api)
    self.config[:api_path] = api
  end

  def project(p)
    self.config[:project] = p
  end


  # update command
  def update(key, &block)
    request_config = {
        user: self.config[:user],
        password: self.config[:password],
        host: self.config[:host],
        api_path: self.config[:api_path],
        project: self.config[:project],
        resource: 'issue/' + key
    }
    self.request = Request.new request_config
    self.instance_eval(&block)
    #self.request_queue.add(self.request)
    p self.request.to_s
    self.request = nil
  end

  def method_missing(name, *args, &block)
    self.request.send(name, args, &block)
  end

end