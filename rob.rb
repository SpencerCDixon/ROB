require 'rack'
require 'pry'
require 'erubis'
require 'haml'

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
        Rack::Response.new(['Error occured. No route'], 404, {})
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

    def root(options)
      cont, act = parse_options(options[:to])
      cont = Object.const_get("#{cont.capitalize}Controller")
      @rules << { path: '/', controller: cont, action: act }
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
      # returns proc that responds to #call
      proc { |e| self.new(e).dispatch(act) }
    end

    def dispatch(act)
      text = self.send(act)
      Rack::Response.new([text], 200, {'Content-Type' => 'text/html'})
    end

    def erb(view, locals = {})
      filename = File.join("app", "views", controller_name, "#{view}.html.erb")
      template = File.read filename
      eruby = Erubis::Eruby.new(template)
      eruby.result(locals.merge(env: env))
    end

    def haml(view, locals = {})
      filename = File.join("app", "views", controller_name, "#{view}.html.haml")
      template = File.read filename
      Haml::Engine.new(template).render(self, locals)
    end

    def render_with_layout(view, layout = :application, context = self)
      filename = File.join("app", "views", controller_name, "#{view}.html.erb")
      template = File.read(filename)
      render_layout(layout) do
        Erubis::Eruby.new(template).result(context.get_binding)
      end
    end

    def render_layout(layout)
      template = File.read("app/views/layouts/#{layout}.html.erb")
      Erubis::Eruby.new(template).result(binding)
    end

    # used for finding views in proper directory
    def controller_name
      klass = self.class
      "#{klass.to_s.gsub(/Controller$/, '').downcase}s"
    end

    # used to yield templates inside each other
    def get_binding
      return binding
    end
  end
end

