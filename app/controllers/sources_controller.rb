class SourcesController < ApplicationController
  def info
    @source = Source.find(params[:id])
    @size_xml = [($1 if @source.xml =~ /(fileSize="[^"]*")/), ($1 if @source.xml =~ /(length="[^"]*")/)].compact.join("\n")
    render :layout => false
  end

end
