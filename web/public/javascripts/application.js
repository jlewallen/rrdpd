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
      this._actions = [];
      this._isAttached = false;
    },

    registerActions: function() {
    },

    transform: function(model) {
      return model;
    },

    queryAndShow: function(url, container) {
      var self = this;
      jQuery.getJSON(url, function(data) {
        self._show(container, self.transform(data));
      });
    },

    remove: function() {
      if (this._top != null) {
        this._top.remove();
        this._top = null;
      }
    },
    
    addAction: function(name, matcher, callback) {
      this._actions.push(new this.Action(name, matcher ? matcher : '*', callback));
    },

    getTop: function() {
      return this._top;
    },
    
    _render: function(path, model) {
      this._model = model;
      var template = new EJS({ url: path + ".ejs" });
      return $(template.render({ model: this._model }));
    },

    _show: function(container, model) {
      var dom = this._render(this._templateName, model);
      this._top = this.place($(container), dom);
      this._actions = [];
      this.registerActions();
      this._attachActions();
      this.afterRender();
    },

    place: function(container, dom) {
      if (this._top != null) {
        $(this._top).before(dom).remove();
      }
      else {
        container.append(dom);
      }
      return dom;
    },

    afterRender: function() {
    },

    Action: Class.extend({
      initialize: function(name, selector, callback) {
        this.name = name;
        this.selector = selector;
        this.callback = callback;
      }
    }),
    
    _attachActions: function() {
      var self = this;
      for (var i = 0; i < this._actions.length; i++) {
        var action = this._actions[i];
        this._top.bind(action.name, { action: action }, function(ev, data) {
          return self._onEvent(ev, data);
        });
      }
      this._isAttached = true;
    },
    
    _onEvent: function(ev, data) {
      var action = ev.data.action;
      var target = ev.target;
      var matched = false;
      var selectedNodes = $(action.selector);
      if ($.inArray(target, selectedNodes) >= 0) {
        ev.receiver = ev.target;
        matched = true;
      }
      else {
        $.each(selectedNodes, function(i, child) {
          if ($.inArray(target, $(child).find("*")) >= 0) {
            matched = true;
            ev.receiver = child;
            return false;
          }
          return true;
        });
      }
      if (matched) {
        return this[action.callback](ev, data);
      }
      return true;
    }
  });

  global.WelcomeController = ApplicationController.extend({
    initialize: function() {
      this._super('/ejs/menu');
      this._map = {};
      this.queryAndShow('/query/categorized', '#menu');
    },

    registerActions: function() {
      this.addAction('click', '.clear_all_graphs', '_clearAllGraphs');
      this.addAction('click', '.renders', '_graphableSelected');
    },

    _graphableSelected: function(ev) {
      var node = $(ev.receiver);                      
      var key = node.property('key');
      if (!node.hasClass('visible'))
      {
        this._map[key] = new GraphController(key);
      }
      else
      {
        this._map[key].remove();
        delete this._map[key];
      }
      node.toggleClass('visible');
      return false;
    },

    _clearAllGraphs: function() {
      $('.renders.visible').removeClass('visible');
      jQuery.each(this._map, function(k, v) {
        v.remove();
      });
      this._map = {}; 
      return false;
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
      this._uri = uri;
      this.queryAndShow(uri, "#canvas");
    },

    transform: function(model) {
      return new GraphModel(model);
    },

    registerActions: function() {
      this.addAction('click', '.displays', '_onDisplay');
    },

    afterRender: function() {
      $(".displays[data-key='" + this._uri + "']").addClass('visible');
    },

    place: function(container, dom) {
      if (this.getTop() != null) {
        this.getTop().before(dom).remove();
      }
      else {
        container.prepend(dom);
      }
      return dom;
    },

    _onDisplay: function(ev) {
      var receiver = $(ev.receiver);
      this._uri = receiver.property('key');
      this.queryAndShow(this._uri);
      return false;
    }
  });

});
