# Shell Command Abstraction.
#
# Hides away all the details to generate a command.
# And privides an easy interface to interact with shell commands as if
# they were objects.
#
# This is good for the following reasons:
#
# 1. Stadardization.
# 2. Simplicity of code.
# 3. Reduces smells in methods that interpolate values.
class AbstractCommand
  # '%<name>s'.scan(/(%<)(\w+)(>)/)
  # => [["%<", "name", ">"]]
  VARIABLE_REGEX = /(%<)(\w+)(>)/

  def template
    raise 'must implement'
  end

  def variables
    result = []
    template.scan(VARIABLE_REGEX).each do |variable|
      result.push(variable[1])
    end
    result
  end

  def initialize(properties = {})
    variables.each do |variable|
      self.class.send(:attr_accessor, variable.to_sym)
    end
    properties.each do |key, value|
      setter = (key.to_s + '=').to_sym
      send(setter, value)
    end
  end

  def to_s
    bindings = {}
    variables.each do |variable|
      value = instance_variable_get("@#{variable}")
      bindings[variable.to_sym] = value
    end
    format(template % bindings)
  end

  def system
    Kernel.system(to_s)
  end

  def backtick
    `#{to_s}`
  end
end
