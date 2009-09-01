class HomeController < ApplicationController
  # GET /
  def home
    @podcasts = Podcast.parsed.sorted

    # Featured
    @podcast1 = Podcast.find_by_clean_url("COOP") || Podcast.all[0]
    @podcast2 = Podcast.find_by_clean_url("Diggnation") || Podcast.all[1]

    # Tag cloud
    @tags = Tag.all(:order => "taggings_count DESC").sort_by &:rand

    # Surf
    surfed_episodes = if logged_in?
                         current_user.surfed_episodes.empty? ? [0] : current_user.surfed_episodes.map(&:id) # empty array evals to [NULL], which breaks the query
                       else
                         !has_unclaimed_record?(UserSurfedEpisode) ? [0] : session[:unclaimed_records]['UserSurfedEpisode'].map { |_| UserSurfedEpisode.find(_).episode.id }
                       end

    @surf_episode = Episode.first(:joins => :sources_with_preview_and_screenshot,
                                  :order => "published_at DESC", 
                                  :conditions => ["episodes.published_at > ? AND episodes.id NOT IN (?)", 30.days.ago, surfed_episodes])
    @surf_episode = Episode.first(:order => "published_at DESC",
                                  :joins => :sources_with_preview_and_screenshot) if @surf_episode.nil?
  end

  # POST /surf/next?episode_id=1
  # POST /surf/previous?episode_id=1
  def surf
    @episode = Episode.find(params[:episode_id])
    if logged_in?
      current_user.surfed_episodes << @episode unless current_user.surfed_episodes.include?(@episode)
    else
      remember_unclaimed_record(UserSurfedEpisode.create(:episode => @episode))
    end

    @surf_episode = params[:direction] == 'previous' ? previous_surfed_episode : next_surfed_episode
    
    respond_to do |format|
      if @surf_episode.nil?
        format.js { head(404) }
      else
        format.js { render :partial => "surf_episode" }
      end
    end
  end
  
  private
  def next_surfed_episode # AKA the next one that's older
    Episode.first(:joins => :sources_with_preview_and_screenshot, 
      :order => "published_at DESC", 
      :conditions => ["episodes.published_at < ? AND episodes.published_at > ? AND episodes.id != ?", @episode.published_at, 30.days.ago, @episode.id])
  end
  
  def previous_surfed_episode # AKA the next one that's newer
    Episode.first(:joins => :sources_with_preview_and_screenshot, 
      :order => "published_at ASC", 
      :conditions => ["episodes.published_at > ? AND episodes.id != ?", @episode.published_at, @episode.id])
  end
end
