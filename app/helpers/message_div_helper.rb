module MessageDivHelper
  def message_div_for(kind, *args, &block)
    value, options, div_options = args
    options ||= {}
    div_options ||= {}
  
    kind = kind.to_sym
    options[:unless_blank] = true unless options.include?(:unless_blank)
    options[:image] = true if [:notice, :success, :error].include?(kind) && !options.include?(:image)
    div_options[:class] = ["message-div", div_options[:class].to_s, kind.to_s].reject(&:blank?).join(" ")
  
    div_content = block_given? ? (respond_to?(:capture_haml) ? capture_haml(&block) : capture(&block)).chomp : value
    return "" if options[:unless_blank] && div_content.blank?
  
    image_content = ""
    if options.delete(:image)
      image = case kind
        when :notice  then "information"
        when :success then "accept"
        when :error   then "exclamation"
      end
      image_div_options = { :class => 'message-div-icon' }
      image_content = content_tag(:div, image_tag("vendor/silk/#{image}.png", :alt => kind.to_s), image_div_options)
    end
  
    div = content_tag(:div, image_content + content_tag(:div, div_content, :class => "message-div-content"), div_options)
    # PATCH: Mark content as HTML-safe
    block_given? ? safe_concat(div) : div
  end
  
  def message_divs
    message_div_for(:success, (flash[:success] || @success)) +
    message_div_for(:error,   (flash[:error]   || @error)) +
    message_div_for(:notice,  (flash[:notice]  || @notice))
  end
end