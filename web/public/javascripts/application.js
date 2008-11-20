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
        if (!$(this).hasClass('visible'))
        {
          var graphController = new GraphController({});
          graphController.show("#canvas", { title: this.title, url: this.href });
          self._map[this.href] = graphController;
        }
        else
        {
          self._map[this.href].remove();
          delete self._map[this.href];
        }
        $(this).toggleClass('visible');
        return false;
      });
      $('a.clear_all_graphs').click(function() {
        self.clearAllGraphs();
      });
    },

    clearAllGraphs: function() {
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

});
