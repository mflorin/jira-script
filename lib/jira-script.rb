require 'jira-script/request'
require 'jira-script/request_exception'

module Jira

# Jira class wrapper that basically runs the script
class Dispatcher
  attr_accessor :config, :request_queue

  def initialize
    self.config = {
        api_path: 'rest/api/2',
        default_issue_type: 'Story',
        default_subtask_type: 'Technical task',
        verbosity: 1
    }
  end

  # config related methods
  def user(u)
    config[:user] = u
  end

  def password(p)
    config[:password] = p
  end

  def host(h)
    config[:host] = h
  end

  def api_path(api)
    config[:api_path] = api
  end

  def project(p)
    config[:project] = p
  end

  def quite(on)
    self.config[:verbosity] = 0 if on
  end

  def verbosity(v)
    self.config[:verbosity] = v
  end

  # build request config
  def _get_request_config(res, type)
    {
        user: config[:user],
        password: config[:password],
        host: config[:host],
        api_path: config[:api_path],
        project: config[:project],
        http_request_type: type,
        resource: res,
        default_issue_type: config[:default_issue_type],
        default_subtask_type: config[:default_subtask_type],
        verbosity: config[:verbosity]
    }
  end

  # update command
  def update(key, &block)
    raise RequestException, "No update definition provided for issue #{key}" unless block_given?
    request_config = _get_request_config('issue/' + key, :put)
    request = Request.new(:update, request_config)
    request.key = key
    request.instance_eval(&block)
    request.run
  end

  def create(summary, &block)
    # create new request
    request_config = _get_request_config('issue', :post)
    request = Request.new(:create, request_config)
    request.summary summary
    request.project config[:project]

    request.instance_eval(&block) if block_given?

    # run request
    request.run
  end
end

def self.run(&block)
  Dispatcher.new.instance_eval(&block)
rescue RequestException => e
  p "ERROR: #{e.message}"
  puts e.backtrace
end

end