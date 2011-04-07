// Copied from other projects
// Upgraded to Rails 3

jQuery(function($) {
  var csrf_token = $('meta[name=csrf-token]').attr('content'),
      csrf_param = $('meta[name=csrf-param]').attr('content');
  
  $("a.delete").click(function(event) {
    var msg = this.title;
    if (confirm(msg)) {
      var action = this.href.replace(/\/delete\/?/, "");
      
      // TODO: Simplify this (see rails.js)
      
      var f = document.createElement("form");
      f.id = "delete-form";
      f.style.display = "none";
      f.method = "post";
      f.action = action;
      
      var m = document.createElement("input");
      m.type = "hidden";
      m.name = "_method";
      m.value = "delete";
      
      var p = document.createElement("input");
      p.type = "hidden";
      p.name = csrf_param;
      p.value = csrf_token;
      
      f.appendChild(m);
      f.appendChild(p);
      document.body.appendChild(f);
      f.submit();
    }
    event.preventDefault();
  })
})