class SourcesController < ApplicationController
  def info
    @source = Source.find(params[:id])
    render :layout => 'info'
  end

end
