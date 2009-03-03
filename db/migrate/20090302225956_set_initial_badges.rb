class SetInitialBadges < ActiveRecord::Migration
  BADGES = %w(hd current stale archive explicit creativecommons audio video widescreen)

  def self.up
    BADGES.each do |tag|
      tag = Tag.find_or_create_by_name(tag)
      tag.update_attribute(:badge, true)
    end
  end

  def self.down
    BADGES.each do |tag|
      tag = Tag.find_by_name(tag)
      tag.update_attribute(:badge, false)
    end
  end
end
