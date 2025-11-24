module ApplicationHelper
  def meta_description(text)
    content_for :description, text
  end

  def meta_title(text)
    content_for :title, text
  end

  def meta_robots(text)
    content_for :robots, text
  end
end
