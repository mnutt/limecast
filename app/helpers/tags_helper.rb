module TagsHelper
  def link_to_tag(tag)
    link_to(tag.name, tag_url(:tag => tag.name))
  end
end
