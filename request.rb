require 'json'
require 'typhoeus'

# Generic Jira request
class Request
  # request config - host, api resource, etc
  attr_accessor :config

  # request data to send to server
  attr_accessor :json_data

  # request fields that were set
  attr_accessor :fields

  # mapping between our dsl keywords and jira's json fields
  attr_accessor :data_map

  # request parent - used when creating subtasks
  attr_accessor :request_parent

  # request response
  attr_accessor :response

  # request children
  attr_accessor :children

  # request type (create, update)
  attr_accessor :request_type

  # issue key
  attr_accessor :key

  def initialize(type, config = {})
    self.request_type = type
    self.config = config
    self.fields = {}
    self.request_parent = nil
    self.json_data = {}
    self.children = []
    self.key = nil
    init_data_map
  end

  def init_data_map
    self.data_map = {
        project: 'fields/project/key',
        parent: 'fields/parent/key',
        summary: 'fields/summary',
        description: 'fields/description',
        type: 'fields/issuetype/name',
        assignee: 'fields/assignee/name',
        estimate: 'fields/timetracking/originalEstimate',
        remaining: 'fields/timetracking/remainingEstimate',
        components: 'fields/components',
        labels: 'fields/labels'
    }
  end

  def to_json
    JSON.generate(json_data)
  end

  def to_s
    json_data
  end

  def _set_default_type
    # set default type if empty
    return if fields.key?(:type)
    if fields.key?(:parent)
      type config[:default_subtask_type]
    else
      type config[:default_issue_type]
    end
  end

  def _set_xpath(h, xpath, value)
    len = xpath.length
    pos = xpath.index('/')
    if pos.nil?
      h[xpath.to_sym] = value
    else
      key = xpath[0..pos - 1].to_sym
      h[key] = h[key] || {}
      _set_xpath(h[key], xpath[pos + 1..len], value)
    end
    h
  end

  def _set_field(name, val)
    raise "Invalid request parameter #{name}" unless data_map.key?(name)
    fields[name] = val
    _set_xpath(json_data, data_map[name], val)
  end

  def _error(msg)
    if request_type == :create
      raise "Error trying to create ticket #{fields[:summary]}: #{msg}"
    elsif request_type == :update
      raise "Error trying to update ticket #{key}: #{msg}"
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    data_map.key?(method_name) || super
  end

  def method_missing(name, *args, &block)
    if data_map.key?(name)
      _set_field(name, args[0])
    else
      super
    end
  end

  def run
    ret = nil
    _set_default_type
    url = [config[:host], config[:api_path], config[:resource]].join('/')
    p to_json
    req = Typhoeus::Request.new(
        url,
        ssl_verifypeer: false,
        method: config[:http_request_type],
        userpwd: "#{config[:user]}:#{config[:password]}",
        body: to_json,
        headers: { 'Content-Type' => 'application/json' }
    )
    req.on_complete do |response|
      if response.success?
        self.response = JSON.parse(response.body, symbolize_names: true)
        ret = self.response[:key]
        self.key = ret if request_type == :create
        unless children.empty?
          children.each do |child|
            child.parent key
            child.run
          end
        end
      elsif response.timed_out?
        _error('timeout')
      elsif response.code.zero?
        # Could not get an http response, something's wrong.
        _error(response.return_message)
      else
        # Received a non-successful http response.
        _error('HTTP request failed: ' + response.code.to_s + ' / message: ' + response.body)
      end
    end

    req.run

    ret
  end

  def create(summary, &block)
    subtask(summary, &block)
  end

  def subtask(summary, &block)
    raise "Sub-task #{fields[:summary]} cannot have other sub-tasks" unless request_parent.nil?
    request = Request.new(:create, config)
    request.config[:http_request_type] = :post
    request.request_parent = self
    children.push request
    request.summary summary
    request.project fields[:project]
    request.instance_eval(&block) if block_given?
  end

  def components(*args)
    vals = []
    args.each do |arg|
      vals.push name: arg
    end

    _set_field(:components, vals)
  end

  def labels(*args)
    _set_field(:labels, [*args])
  end
end