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
      this._model = null;
    },

    _render: function(path, model) {
      this._model = model;
      var template = new EJS({ url: path + ".ejs" });
      return $(template.render({ model: this._model }));
    },

    _show: function(container, model, emptyContainer) {
      this._top = this._render(this._templateName, model);
      if (emptyContainer) {
        $(container).empty();
      }
      $(container).append(this._top);
      this.registerActions();
    },

    _transform: function(model) {
      return model;
    },

    queryAndShow: function(url, container) {
      var self = this;
      jQuery.getJSON(url, function(data) {
        self._show(container, self._transform(data), true);
      });
    },

    queryAndAppend: function(url, container) {
      var self = this;
      jQuery.getJSON(url, function(data) {
        self._show(container, self._transform(data), false);
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
      this.queryAndShow("/query/categorized", "#menu");
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
        this._map[key] = new GraphController(key);
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

  global.GraphModel = Class.extend({
    initialize: function(model) {
      jQuery.extend(this, model);
    },

    defaultGraph: function() {
      return this.graphs[0];
    }
  });

  global.GraphController = ApplicationController.extend({
    initialize: function(uri) {
      this._super("/ejs/graph");
      this.queryAndAppend(uri, "#canvas");
    },

    _transform: function(model) {
      return new GraphModel(model);
    },

    registerActions: function() {
      var self = this;
    }
  });

});
