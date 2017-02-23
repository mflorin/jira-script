require 'request'
require 'request_queue'

class Jira

  attr_accessor :config, :request_queue, :request

  def initialize
    self.config = {
        api_path: 'rest/api/2'
    }
    self.request_queue = RequestQueue.new
  end

  def self.run(&block)
    j = Jira.new
    Jira.new.instance_eval(&block)
    j.request_queue.run
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

  # build request config
  def _get_request_config(res, type)
    {
        user: self.config[:user],
        password: self.config[:password],
        host: self.config[:host],
        api_path: self.config[:api_path],
        project: self.config[:project],
        request_type: type,
        resource: res
    }
  end

  def _show_result(response, tag, success_msg)
    if response.success?
      p "[#{tag}] #{success_msg}"
    elsif response.timed_out?
      p "[#{tag}] timeout"
    elsif response.code == 0
      p "[#{tag}] #{response.return_message}"
    else
      p "[#{tag}] request failed: #{response.code.to_s}"
      p response.body
    end
  end

  # update command
  def update(key, &block)
    request_config = self._get_request_config('issue/' + key, :put)
    raise Exception.new 'cannot start a new command inside another' unless self.request.nil?
    self.request = Request.new(request_config)
    self.instance_eval(&block)
    response = self.request_queue.add(self.request)
    self._show_result(response, key, 'update successful')
    self.request = nil
  end

  def create(summary, &block)
    request_config = self._get_request_config('issue', :post)
    raise Exception.new 'cannot start a new command inside another' unless self.request.nil?
    self.request = Request.new(request_config)
    self.request.summary summary
    self.request.project self.config[:project]
    self.instance_eval(&block)
    response = self.request_queue.add(self.request)
    self._show_result(response, summary, 'created successfully')
    p self.request.to_s
    self.request = nil
  end

  def method_missing(name, *args, &block)
    self.request.send(name, args, &block)
  end

end