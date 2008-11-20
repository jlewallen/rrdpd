jQuery.fn.extend({
  property: function(value) {
    var properties = [];
    this.each(function(i, node) {
      var attr = node.attributes["data-" + value];
      if (attr) {
        properties.unshift(attr.value);
      }
    });
    if (properties.length == 1) {
      return properties[0];
    }
    return properties;
  }
});

$(function() {
  var global = window;

  global.ApplicationController = Class.extend({
    initialize: function(templateName) {
      this._templateName = templateName;
      this._top = null;
    },

    render: function(path, model) {
      var template = new EJS({ url: path + ".ejs" });
      return template.render({ model: model });
    },

    show: function(container, model) {
      var rendered = this.render(this._templateName, model);
      this._top = $(rendered);
      $(container).append(this._top);
      this.registerActions();
    },

    queryAndShow: function(url, container) {
      var self = this;
      jQuery.getJSON(url, function(data) {
        self.show(container, data);
      });
    },

    remove: function() {
      if (this._top != null) {
        this._top.remove();
        this._top = null;
      }
    },

    registerActions: function() {
    }
  });

  global.WelcomeController = ApplicationController.extend({
    initialize: function() {
      this._super("/ejs/menu");
      this._map = {};
      this.queryAndShow("/events/categorized", "#menu");
    },

    registerActions: function() {
      var self = this;
      $('.renders').click(function(target) {
        self._graphableSelected(this);
        return false;
      });
      
      $('a.clear_all_graphs').click(function() {
        self._clearAllGraphs();
        return false;
      });
    },

    _graphableSelected: function(selected) {
      var key = $(selected).property("key");
      if (!$(selected).hasClass('visible'))
      {
        var graphController = new GraphController({});
        graphController.show("#canvas", { title: selected.title, url: selected.href });
        this._map[key] = graphController;
      }
      else
      {
        this._map[key].remove();
        delete this._map[key];
      }
      $(selected).toggleClass('visible');
    },

    _clearAllGraphs: function() {
      $('.renders.visible').removeClass('visible');
      jQuery.each(this._map, function(k, v) {
        v.remove();
      });
      this._map = {}; 
    }
  });

  global.GraphController = ApplicationController.extend({
    initialize: function(model) {
      this._super("/ejs/graph");
      this.model = model;
    },

    registerActions: function() {
      var self = this;
    }
  });

  global.Urls = {};

  global.Urls.ForGraph = function(graph, starting, ending, w, h) {
    return "/render/" + graph.source + "/" + graph.name + "/" + graph.grapher
     + "/" + starting + "/" + ending + "/" + w + "/" + h;
  };

});
