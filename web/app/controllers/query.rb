require 'json_printer'
require 'json'

class Query < Application

  provides :json, :html

  def categorized
    @query = DataManager.find_categorized
    @query.instance_eval "def to_html; '<pre>' + JsonPrinter.render(JSON.parse(to_json)) + '</pre>'; end"
    display @query
  end

  def graph(category, name, source, counter, starting)
    @query = DataManager.find_item(category, name).browser(source, counter.to_sym, { :starting => starting })
    @query.instance_eval "def to_html; '<pre>' + JsonPrinter.render(JSON.parse(to_json)) + '</pre>'; end"
    display @query
  end

end
