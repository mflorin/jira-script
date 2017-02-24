require 'json'

class Request

  # request config - host, api resource, etc
  attr_accessor :config

  # request data to send to server
  attr_accessor :data

  # request fields that were set
  attr_accessor :fields

  # mapping between our dsl keywords and jira's json fields
  attr_accessor :data_map

  # request parent - used when creating subtasks
  attr_accessor :request_parent

  # request response
  attr_accessor :response

  def initialize(config = {})
    self.config = config
    self.fields = {}
    self.request_parent = nil
    self.data_map = {
        project: 'fields/project/key',
        parent: 'fields/parent/key',
        summary: 'fields/summary',
        description: 'fields/description',
        type: 'fields/issuetype/name',
        assignee: 'fields/assignee/name',
        estimate: 'fields/timetracking/originalEstimate',
        remaining: 'fields/timetracking/remainingEstimate'
    }
    self.data = {}
  end

  def to_json
    JSON.generate(self.data)
  end

  def _set_xpath(h, xpath, value)
    len = xpath.length
    pos = xpath.index('/')
    if pos.nil?
      h[xpath.to_sym] = value
    else
      key = xpath[0..pos - 1].to_sym
      h[key] = h[key] || {}
      self._set_xpath(h[key], xpath[pos + 1..len], value)
    end
    h
  end

  def method_missing(name, *args, &block)
    if self.data_map.key?(name)
      self.fields[name] = *args[0]
      self._set_xpath(self.data, self.data_map[name], *args[0])
    else
      raise Exception.new 'Invalid request parameter: ' + name.to_s
    end
  end

  def to_s
    self.data
  end
end