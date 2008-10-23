Event.observe(document, 'dom:loaded', function() {
  // check all div classes and show/hide as necessary
  $("archived_posts").select('div').each(function(div) {
    var closed = false;
    div.classNames().each(function(class_name) {
      if (class_name == 'closed') {
        closed = true;
      }
    });
    if (closed) {
      div.next().hide();
    }
  });

  //////////////////////////////////////////
  // add event observes for tree clicking //
  //////////////////////////////////////////
  
  // first add click for years
  $$('li.year').each(function(li_year){
    var div_year = li_year.down();
    Event.observe(div_year, 'click', function(event_obj) {
      var months_ul = div_year.next();
      if (months_ul.style.display == 'none') {
        div_year.removeClassName('closed');
        div_year.addClassName('open');
        months_ul.show();
      } else {
        div_year.removeClassName('open');
        div_year.addClassName('closed');
        months_ul.hide();
      }
    });
  });

  // add click for months
  $$('li.month').each(function(li_month){
    var div_month = li_month.down();
    Event.observe(div_month, 'click', function(event_obj) {
      var posts_ul = div_month.next();
      if (posts_ul.style.display == 'none') {
        div_month.removeClassName('closed');
        div_month.addClassName('open');
        posts_ul.show();
      } else {
        div_month.removeClassName('open');
        div_month.addClassName('closed');
        posts_ul.hide();
      }
    });
  });
});
