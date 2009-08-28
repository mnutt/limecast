class HomeController < ApplicationController
  # GET /
  def home
    @podcasts = Podcast.parsed.sorted

    # Featured
    @podcast1 = Podcast.find_by_clean_url("COOP") || Podcast.all[0]
    @podcast2 = Podcast.find_by_clean_url("Diggnation") || Podcast.all[1]

    # Tag cloud
    @tags = Tag.all(:order => "taggings_count DESC").sort_by &:rand

    # Surf -- first/last is an expanding window of watched episodes
    @surfed_episode = Episode.newest.first(:joins => :sources_with_preview_and_screenshot,
      :conditions => ["episodes.published_at > ? AND episodes.id NOT IN (?)", 30.days.ago, (current_user.surfed_episodes.empty? ? [0] : current_user.surfed_episodes)])
  end

  # POST /surf?episode_id=1
  def surf
    @episode = Episode.find(params[:episode_id])
    current_user.surfed_episodes << @episode

    @surfed_episode = Episode.newest.first(:joins => :sources_with_preview_and_screenshot,
      :conditions => ["episodes.published_at > ? AND episodes.id NOT IN (?)", 30.days.ago, (current_user.surfed_episodes.empty? ? [0] : current_user.surfed_episodes)])
    
    respond_to do |format|
      format.js { }
    end
  end
end
