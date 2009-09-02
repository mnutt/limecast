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
    @episode = SurfEpisode.first(:order => "RAND()").episode
  end

  # POST /surf/next?episode_id=1
  # POST /surf/previous?episode_id=1
  def surf
    @last_episode = Episode.find(params[:episode_id])
    @last_surf_episode = @last_episode.surf_episode
    order = params[:direction] == 'previous' ? @last_surf_episode.order-1 : @last_surf_episode.order+1
    order = order < 1 ? SurfEpisode.maximum(:order) : (order > SurfEpisode.maximum(:order) ? 1 : order) 
    
    @episode = (SurfEpisode.find_by_order(order) || SurfEpisode.last).episode
    
    respond_to do |format|
      if @episode.nil?
        format.js { head(404) }
      else
        format.js { render :partial => "surf_episode" }
      end
    end
  end
  end
