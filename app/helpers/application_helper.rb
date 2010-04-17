module ApplicationHelper
  def format_title(title)
    [Riggifier[:window_title], @title].select {|x| x.present? }.join(": ")
  end
end
