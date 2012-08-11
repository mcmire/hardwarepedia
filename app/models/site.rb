
class Site < Sequel::Model
  include Base

  def before_create
    super
    self.webkey ||= name.try(:parameterize)
  end
end
