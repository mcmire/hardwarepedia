module ApplicationHelper
  def require_javascripts
    reqs = []
    if Rails.env.production?
      reqs << ["jquery", "http://ajax.googleapis.com/ajax/libs/jquery/1.4.4/jquery.min.js"]
    else
      reqs << ["jquery", "/javascripts/vendor/jquery-1.4.4.min.js"]
    end
    reqs << ["underscore", "/javascripts/vendor/underscore-1.1.4.min.js"]
    #reqs << "/javascripts/vendor/jquery.cookie.js"
    reqs << "/javascripts/vendor/rails.js"
    reqs << "/javascripts/app/ujs_destroy.js"
    reqs << "/javascripts/app/application.js"
    
    reqs_as_js = '[' + reqs.map {|req|
      path, name = [req].flatten.reverse
      path = javascript_path(path)
      if name
        %|{"#{name}": "#{path}"}|
      else
        %|"#{path}"|
      end
    }.join(",\n") + ']'
    
    javascript = <<-EOT
      var reqs = #{reqs_as_js};
      head.js(reqs).ready(function() {
        (function(window, document, jq, us, undefined) {
          #{content_for(:javascript)}
        })(window, window.document, window.jQuery, window._);
      })
    EOT
    javascript_tag(javascript)
  end
  
  def sorted_link_to(link_text, sort_key, params={})
    params[:sort_key] = sort_key
    params[:sort_order] = inv_sort_order_of(sort_key)
    link_to(link_text, params)
  end
  
  def inv_sort_order_of(sort_key)
    if self.sort_key == sort_key
      (self.sort_order == "asc") ? "desc" : "asc"
    else
      return "asc"
    end
  end
end
