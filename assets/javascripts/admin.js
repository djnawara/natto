var DJN = DJN ? DJN : {};

//Admin
// Usage: var myVar = new DJN.Admin();
DJN.Admin = Class.create({
  initialize: function (id, params) {
    self = this;
    this.adminOptions;
    Event.observe(window,"keypress",function(ev){
      var key = ev.which || ev.keyCode
      switch(key){
        case Event.KEY_ESC: // escape key
        self.closeAdmin();
        break;
        case 32: // just spacebar
        if (ev.shiftKey) {
          if(!self.modal){
            self.drawWindow();
            self.openAdmin();
            self.updateWindow('/admin');
          }else{
            self.openAdmin();
          }
        }
        break;
        case 13: // return key
          self.processInput();
        break;
      }
    })
  },
  drawWindow: function(){
    this.modal = new Element('div', { 'class': 'admin_modal', style: 'position:absolute; left:100px;top:100px;display:none;' }).update("<h1>loading..</h1>");
    $("content").insert(this.modal);
  },
  openAdmin: function(){
    new Effect.Appear($(self.modal),{duration:.5,to:.75,afterFinish: function(){$(self.adminField).focus()}});
  },
  closeAdmin: function(){
    new Effect.Fade(this.modal);
  },
  updateWindow: function(adminPath){
    self = this;
    self.adminArray = [];
    self.adminField = new Element('input',{ 'type': "text/css", 'id': "admin_field"});
    $(self.modal).update(self.adminField);
    adminPath = adminPath || admin
    new Ajax.Request(adminPath , {onSuccess: function(response){
      self.adminOptions = response.responseText.evalJSON();
      self.adminOptions.each(function(item){
      self.adminArray.push(item.title);
      });
    }});
    $(self.modal).insert("<div id='admin_results'></div>");
    new Autocompleter.Local('admin_field', 'admin_results', self.adminArray, { });
    $(self.adminField).focus();
  },
  processInput: function(){
    if ($(self.adminField).value.length == 0) { exit; } // drop out if we have no input
    input = $(self.adminField).value.split(' ');        // split user input by space
    href = '/' + input[0];                              // dump the controller name
    if (input.length >= 2) {                            // if we have another input item...
      switch(input[1]){                                 // switch on it:
        case 'index': break;                            // just controller name is fine
        case 'sitemap': href = '/sitemap'; break;
        case 'show_by_title':
          if (input.length < 3) { exit; }               // don't process w/o third arg
          href = '/show/';
          for (x=2; x < input.length; x++) {            // remaining args dumped as title
            if (x > 2) { href += '_'; }
            href += input[x];
          }
        break;
        default:                                        // just dump the user input
          for (x=1; x < input.length; x++) {
            href += '/' + input[x];
          }
        break;
      }
    }
    window.location = href;                             // go!
  },
  createTypeahead: function(){
    alert('foo')
  }
});
