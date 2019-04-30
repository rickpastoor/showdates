function debounce(func, wait, immediate) {
	var timeout;
	return function() {
		var context = this, args = arguments;
		var later = function() {
			timeout = null;
			if (!immediate) func.apply(context, args);
		};
		var callNow = immediate && !timeout;
		clearTimeout(timeout);
		timeout = setTimeout(later, wait);
		if (callNow) func.apply(context, args);
	};
};

!function( $ ){

  "use strict"

  var ShowSearch = function ( element, options ) {
    this.$element = $(element);
    this.options = $.extend({}, $.fn.showSearch.defaults, options);
    this.$menu = $(this.options.menu).appendTo('body');
    this.source = this.options.source;
    this.shown = false;
    this.listen();
  };

  ShowSearch.prototype = {

    constructor: ShowSearch

  , select: function () {
	  window.location = this.$menu.find('.active a').attr('href');
    }

  , show: function () {
      var pos = $.extend({}, this.$element.offset(), {
        height: this.$element[0].offsetHeight
      })

      this.$menu.css({
        top: pos.top + pos.height + 6
      , left: pos.left
      })

      this.$menu.show();
      this.shown = true;
      return this;
    }

  , hide: function () {
      this.$menu.hide()
      this.shown = false
      return this
    }

  , lookup: function (event) {
      var that = this
        , items = new Array()
        , q;

      // Get query
      this.query = this.$element.val();

      // If we do not have a query, hide
      if (!this.query) {
        return this.shown ? this.hide() : this;
      }

      // Get results from source and render
      var results = $.grep(this.source, function(el, idx) {
        return (el.title.toLowerCase().indexOf(that.query.toLowerCase()) > -1);
      });

      // If we have items, show results, else hide!
      if (!results.length) {
        return that.shown ? that.hide() : that;
      }

      return that.render(results.slice(0, that.options.items)).show();
    }

  , render: function (items) {
      var that = this

      items = $(items).map(function (i, item) {
        i = $(that.options.item)
        i.find('a').attr('href', '/show/' + item.id)
        i.find('.title').html(item.title)
        i.find('img').attr('src', '/uploads/shows/poster-' + item.id + '.jpg')
        return i[0]
      })

      items.first().addClass('active')
      this.$menu.html(items)
      return this
    }

  , next: function (event) {
      var active = this.$menu.find('.active').removeClass('active')
        , next = active.next()

      if (!next.length) {
        next = $(this.$menu.find('li')[0])
      }

      next.addClass('active')
    }

  , prev: function (event) {
      var active = this.$menu.find('.active').removeClass('active')
        , prev = active.prev()

      if (!prev.length) {
        prev = this.$menu.find('li').last()
      }

      prev.addClass('active')
    }

  , listen: function () {
	  // Attach different types of listeners
      this.$element
        .on('blur',     $.proxy(this.blur, this))
        .on('keypress', $.proxy(this.keypress, this))
        .on('click', $.proxy(this.lookup, this))
        .on('keyup', debounce($.proxy(this.keyup, this), 200, false));

      // Attach listeners to the menu
      this.$menu
        .on('click', $.proxy(this.click, this))
        .on('mouseenter', 'li', $.proxy(this.mouseenter, this));
    }

  , keyup: function (e) {
      e.stopPropagation()

      switch(e.keyCode) {
        case 40: // down arrow
        case 38: // up arrow
          break

        case 9: // tab
        case 13: // enter
          if (!this.shown) { this.lookup(); return; }
          this.select();
          break

        default:
          this.lookup()
      }

  }

  , keypress: function (e) {
      e.stopPropagation()
      if (!this.shown) return

      switch(e.keyCode) {
        case 9: // tab
          e.preventDefault();
          break;

        case 13: // enter
          if (!this.shown) { this.lookup(); return; }
          this.select();
          break

        case 27: // escape
    	  this.$element.val('');
          this.hide()
          e.preventDefault()
          break

        case 38: // up arrow
          e.preventDefault()
          this.prev()
          break

        case 40: // down arrow
          e.preventDefault()
          this.next()
          break
      }
    }

  , blur: function (e) {
      var that = this;
      e.stopPropagation();
      e.preventDefault();
      setTimeout(function () { that.hide(); }, 150);
    }

  , click: function (e) {
      e.stopPropagation()
      e.preventDefault()
      this.select()
    }

  , mouseenter: function (e) {
      this.$menu.find('.active').removeClass('active')
      $(e.currentTarget).addClass('active')
    }

  }


  /* SHOWSEARCH PLUGIN DEFINITION
   * =========================== */

  $.fn.showSearch = function ( option ) {
    return this.each(function () {
      var $this = $(this)
        , options = typeof option == 'object' && option;
      var data = new ShowSearch(this, options)
    })
  }

  $.fn.showSearch.defaults = {
    source: []
  , items: 8
  , menu: '<ul class="dropdown-menu"></ul>'
  , item: '<li><a href="#" class="poster"><img src="" /></a><a href="#" class="title"></a></li>'
  }

  $.fn.showSearch.Constructor = ShowSearch

}( window.jQuery )
