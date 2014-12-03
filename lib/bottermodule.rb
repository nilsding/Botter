$modules ||= {
    loaded: {},
    callbacks: {}
}

class BotterModule

  attr_reader :name
  attr_reader :display_name
  attr_reader :description
  attr_reader :authors
  attr_reader :config

  def initialize
    @authors = []
    @display_name = 'untitled'
    @description = 'This module does not have a description'
    @config = {}
  end

  def create(name, &block)
    raise "Module #{name} is already loaded" if $modules.include? name
    @name = name
    @config = APP_CONFIG['modules']['config'][name]
    instance_eval &block
    $modules[:loaded][name] = self
    puts "-- Loaded module #{@display_name} (#{@name})" if APP_CONFIG["verbose"]
  end

  # Sets the display name.
  def display_name(disp_name)
    @display_name = disp_name
  end

  # Sets the description.
  def description(desc)
    @description = desc
  end

  # Sets the description.
  def authors(*args)
    @authors = args
  end
  alias author authors

  # overwriting method_missing for callbacks (starting with 'on_')
  def method_missing(name, *args, &block)
    n = name.to_s
    super unless n.start_with? 'on_'
    n.sub! /^on_/, ''
    $modules[:callbacks][n.to_sym] ||= []
    $modules[:callbacks][n.to_sym] << block
  end
end
