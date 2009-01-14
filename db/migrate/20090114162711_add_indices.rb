class AddIndices < ActiveRecord::Migration
  def self.up
    # Feeds
    add_index(:feeds, :podcast_id)
    add_index(:feeds, :finder_id)
    
    # Podcasts
    add_index(:podcasts, :owner_id)
    add_index(:podcasts, :clean_url, :unique => true)
    
    # Recommendations
    add_index(:recommendations, [:podcast_id, :related_podcast_id], :unique => true)

    # Ratings
    add_index(:review_ratings, :review_id)
    
    # Reviews
    add_index(:reviews, :user_id)
    add_index(:reviews, :episode_id)

    # Sources
    add_index(:sources, :episode_id)
    add_index(:sources, :feed_id)

    # Users
    add_index(:users, :login, :unique => true)
    add_index(:users, :email, :unique => true)
  end

  def self.down
  end
end
