
class Layouts::Application < Stache::Mustache::View
  def styles
    stylesheet_link_tag 'bundle'
  end

  def scripts
    javascript_include_tag 'bundle'
  end

  def rails_env
    Rails.env.to_s
  end
end
