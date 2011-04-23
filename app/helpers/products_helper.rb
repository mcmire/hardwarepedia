module ProductsHelper
  def m_sorted_link_to(manufacturer, text, sort_key)
    sorted_link_to(text, sort_key, :anchor => manufacturer.webkey)
  end
end