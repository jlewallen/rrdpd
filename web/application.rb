require "rubygems"
require "bundler/setup"
require "erubis"
require "camping"
require "pathname"
require "web/basic_authentication"
require "web/model"
require "active_support"
require "active_support/json"
require 'rrdtool'

Camping.goes :Graphs

module Graphs
  include Camping::BasicAuth

  def authenticate(u, p)
    [u, p] == ['jacob', 'asdfasdf']
  end

  module_function :authenticate

  def service(*a)
    Configuration.load(Graphs.path.join("../config/rrdpd.conf"))
    super(*a)
  end

  def self.views
    path.join('views')
  end

  def self.path
    Pathname.new(File.dirname(__FILE__))
  end

  set :views, Graphs.views

  module Models
  end

  module Controllers
    class Render < R '/(.+)/(.+)/(.+)/(.+)/(.+)/(\d+)/(\d+)'
      def get(source, name, counter, starting, ending, w, h)
        dod = DataManager.find_database(source, name, counter.to_sym)
        database = Struct.new(:path, :title).new(dod.path.to_s, dod.unique_name)
        grapher = graphers[dod.counter]
        image = grapher.graph(database, starting, ending, w, h)
        @headers['Content-Type'] = "image/png"
        image.to_png
      end

      def graphers
        {
          :yesno => YesNoGrapher.new,
          :quartiles => QuartilesGrapher.new
        }
      end
    end

    class Categorized < R '/query/categorized'
      def get()
        query = DataManager.find_categorized
        query.to_json
      end
    end

    class Graph < R '/(.+)/(.+)/(.+)/(.+)/(.+)'
      def get(category, name, source, counter, starting)
        query = DataManager.find_item(category, name).browser(source, counter.to_sym, { :starting => starting })
        query.to_json
      end
    end

    class Index < R '/'
      def get
        render :index
      end
    end

    class Static < R '/(.+)'
      MIME_TYPES = {
        '.html' => 'text/html',
        '.css'  => 'text/css',
        '.js'   => 'text/javascript',
        '.jpg'  => 'image/jpeg',
        '.gif'  => 'image/gif'
      }
      def get(path)
        @headers['Content-Type'] = MIME_TYPES[path[/\.\w+$/, 0]] || "text/plain"
        unless path.include? ".." # prevent directory traversal attacks
          @headers['X-Sendfile'] = Graphs.path.join("public").join(path).to_s
        else
          @status = "403"
          "403 - Invalid path"
        end
      end
    end
  end

  module Views
    def layout
      template = File.read(Graphs.views.join('layout/application.html.erb'))
      erb = Erubis::Eruby.new(template)
      erb.evaluate do
        yield
      end
    end
  end
end
