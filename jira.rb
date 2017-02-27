require 'request'

# Jira class wrapper that basically runs the script
class Jira
  attr_accessor :config, :request_queue

  def initialize
    self.config = {
        api_path: 'rest/api/2',
        default_issue_type: 'Story',
        default_subtask_type: 'Technical task'
    }
  end

  def self.run(&block)
    Jira.new.instance_eval(&block)
  rescue StandardError => e
    p "ERROR: #{e.message}"
    puts e.backtrace
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
        default_subtask_type: config[:default_subtask_type]
    }
  end

  # update command
  def update(key, &block)
    raise "No update definition for issue #{key}" unless block_given?
    request_config = _get_request_config('issue/' + key, :put)
    request = Request.new(:update, request_config)
    request.key = key
    request.instance_eval(&block)
    request.run

    p "Issue #{key} updated successfully"
  end

  def create(summary, &block)
    # create new request
    request_config = _get_request_config('issue', :post)
    request = Request.new(:create, request_config)
    request.summary summary
    request.project config[:project]

    request.instance_eval(&block) if block_given?

    # run request
    k = request.run

    p "Issue #{k}: '#{summary}' created successfully"
  end
end