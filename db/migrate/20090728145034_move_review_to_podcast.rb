class Review
  belongs_to :podcast
  belongs_to :episode
end

class MoveReviewToPodcast < ActiveRecord::Migration
  def self.up
    add_column :reviews, :podcast_id, :integer
    Review.all.each do |review|
      if review.episode && podcast = review.episode.podcast
        review.update_attribute :podcast_id, podcast.id
      end
    end
    remove_column :reviews, :episode_id
  end

  def self.down
    add_column :reviews, :episode_id, :integer
    Review.all.each do |review|
      if review.podcast && episode = review.podcast.episodes.first
        review.update_attribute :episode_id, episode.id
      end
    end
    remove_column :reviews, :podcast_id
  end
end
