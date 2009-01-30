class SourcesController < ApplicationController
  def info
    @source = Source.find(params[:id])
    render :layout => false
  end

end
