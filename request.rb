require 'json'

class Request

  attr_accessor :config, :data, :data_map

  def initialize(config = {})
    self.config = config
    self.data_map = {
        project: 'fields/project/key',
        parent: 'fields/parent/key',
        summary: 'fields/summary',
        description: 'fields/description',
        type: 'fields/issuetype/name',
        assignee: 'fields/assignee/name',
        estimate: 'fields/timeTracking/originalEstimate',
        remaining: 'fields/timeTracking/remainingEstimate'
    }
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
      self._set_xpath(self.data, self.data_map[name], value)
    else
      raise Exception.new 'Invalid request parameter: ' + name
    end
  end

  def to_s
    self.data.to_s
  end
end