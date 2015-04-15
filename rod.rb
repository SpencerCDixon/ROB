require 'rack'
require 'pry'

# Ruby on Bros
module ROB
  class Application
    def call(env)
      if env['PATH_INFO'] == '/favicon.ico'
        return [404, { 'Content-Type' => 'text/html' }, []]
      end

      if app = get_rack_app(env)
        app.call(env)
      else
        [404, { 'Content-Type' => 'text/html' }, ['Error occured sorry broseph']]
      end
    end

    def routes(&block)
      # gets called automatically by config.ru
      @router ||= Router.new
      @router.instance_eval(&block)
    end

    def get_rack_app(env)
      check_url(env)
    end

    def check_url(env)
      path = env["PATH_INFO"]
      @router.rules.each do |rule|
        if rule[:path] == path
          return rule[:controller].action(rule[:action])
        end
      end
      false
    end
  end

  class Router
    attr_reader :rules
    def initialize
      @rules = []
    end

    # will take get '/', to: 'controller#action'
    # and properly hit the right controllers action
    def get(path, options)
      cont, act = parse_options(options[:to])
      cont = Object.const_get("#{cont.capitalize}Controller")
      @rules << { path: path, controller: cont, action: act }
    end

    def parse_options(options)
      controller, action = options.split("#")
      [controller, action]
    end
  end

  class Controller
    attr_reader :env
    def initialize(env)
      @env = env
    end

    # needs to be class method since we're calling on the class object
    def self.action(act)
      proc { |e| self.new(e).dispatch(act) }
    end

    def dispatch(act)
      text = self.send(act)
      [200, {'Content-Type' => 'text/html'}, [text]]
    end
  end
end

class ExampleController < ROB::Controller
  def index
    'index text'
  end

  def example_two
    'this is example two text'
  end
end
