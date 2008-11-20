$(function() {
  var global = window;

  global.ApplicationController = Class.extend({
    initialize: function(templateName) {
      this._templateName = templateName;
    },

    render: function(path, model) {
      var template = new EJS({ url: path + ".ejs" });
      return template.render({ model: model });
    },

    show: function(id, model) {
      var rendered = this.render("/ejs/menu", model);
      $(id).append(rendered);
      this.registerActions();
    },

    registerActions: function() {
    }
  });

  global.WelcomeController = ApplicationController.extend({
    initialize: function() {
      this._super("/ejs/menu");
      this._map = {};
      this.query();
    },

    query: function() {
      var self = this;
      jQuery.getJSON("/events/categorized", function(data) {
        self.show("#menu", data);
      });
    },

    registerActions: function() {
      var self = this;
      $('.renders').click(function(target) {
        if ($(this).hasClass('visible'))
        {
          self._map[this.title].remove();
          delete self._map[this.title];
        }
        else
        {
          var holder = self.renderGraph(this);
          $('#canvas').append(holder);
          self._map[this.title] = holder;
        }
        $(this).toggleClass('visible');
        return false;
      });
    },

    renderGraph: function(target) {
      var holder = $('<div></div>');
      holder.append("<h2>" + target.title + "</h2>");
      holder.append("<img src='" + target.href + "' />");
      return holder;
    }

  });

});
