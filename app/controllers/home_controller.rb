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
    source = Source.with_preview.with_screenshot.first(:order => "published_at DESC",
      :conditions => ["published_at > ? AND episode_id NOT IN (?)", surf_window, surfed_episodes])
    source = Source.with_preview.with_screenshot.first(:order => "published_at DESC") if source.nil?
    @surf_episode = source.episode unless source.nil?
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

    @surf_episode = Source.with_preview.with_screenshot.first(:order => "published_at #{params[:direction] == 'previous' ? 'ASC' : 'DESC'}", 
                      :conditions => ["published_at > ?", surf_window]).episode if @surf_episode.nil?
    
    respond_to do |format|
      if @surf_episode.nil?
        format.js { head(404) }
      else
        format.js { render :partial => "surf_episode" }
      end
    end
  end
  
  private
  def surf_window
    10.days.ago
  end
  
  def next_surfed_episode # AKA the next one that's older
    source = Source.with_preview.with_screenshot.first(:order => "published_at DESC",
      :conditions => ["published_at < ? AND published_at > ? AND episode_id != ?", @episode.published_at, surf_window, @episode.id])
    source.episode unless source.nil?
  end
  
  def previous_surfed_episode # AKA the next one that's newer
    source = Source.with_preview.with_screenshot.first(:order => "published_at ASC",
      :conditions => ["published_at > ? AND published_at > ? AND episode_id != ?", @episode.published_at, surf_window, @episode.id])
    source.episode unless source.nil?
  end
end
