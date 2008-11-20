$(function() {
  var global = window;

  global.ApplicationController = Class.extend({
    initialize: function() {
    }
  });

  global.WelcomeController = ApplicationController.extend({
    initialize: function() {
      this._super();
      this.map = {};
      this.query();
    },

    query: function() {
      var self = this;
      jQuery.getJSON("/events/categorized", function(data) {
        self.render(data);
      });
    },

    render: function(data) {
      var container = $('#menu');
      jQuery.each(data, function(i, category) {
        jQuery.each(category.events, function(j, ev) {
          var panel = $('<li></li>');
          panel.append('<p class="name">' + ev.name + '</p>');
          jQuery.each(ev.sources, function(k, source) {
            jQuery.each(source.types, function(l, type) {
              var link = $("<a class='renders'>" + type.grapher + "</a>");
              link.attr('href', type.url);
              link.attr('title', type.title);
              panel.append(link);
            });
          });
          container.append(panel);
        });
      });
      this.registerActions();
    },

    registerActions: function()
    {
      var self = this;
      console.log($('.renders'));
      $('.renders').click(function(target) {
        if ($(this).hasClass('visible'))
        {
          self.map[this.title].remove();
          delete self.map[this.title];
        }
        else
        {
          var holder = self.renderGraph(this);
          $('#canvas').append(holder);
          self.map[this.title] = holder;
        }
        $(this).toggleClass('visible');
        return false;
      });
    },

    renderGraph: function(target)
    {
      var holder = $('<div></div>');
      holder.append("<h2>" + target.title + "</h2>");
      holder.append("<img src='" + target.href + "' />");
      return holder;
    }

  });

});
