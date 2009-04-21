class SourcesController < ApplicationController
  def show
    @source = Source.find(params[:id])
    
    respond_to do |format|
      format.torrent do
        if @source.torrent.file?
          redirect_to(@source.torrent.url)
        else 
          head(:not_found)
        end
      end
    end
  end
end
