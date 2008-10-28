class Tagging < ActiveRecord::Base
  belongs_to :taggable, :polymorphic => true
  belongs_to :tag

  before_save :map_to_different_tag

  named_scope :podcasts, :conditions => {:taggable_type => 'podcast'}

  protected

  def validate
    if self.tag && self.tag.category?
      if self.taggable && self.taggable.tags.select {|t| t.category? }.size >= 2
        errors.add(:taggable, 'already has 2 category tags')
      end
    end
  end

  def map_to_different_tag
    return if self.tag.nil?

    self.tag = self.tag.map_to until self.tag.map_to.nil?
  end
end
