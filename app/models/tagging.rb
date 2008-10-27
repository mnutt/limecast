class Tagging < ActiveRecord::Base
  belongs_to :taggable, :polymorphic => true
  belongs_to :tag

  named_scope :podcasts, :conditions => {:taggable_type => 'podcast'}
end
