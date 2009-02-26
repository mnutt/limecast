#Requires classifier gem
#GSL, along with the rb-gsl gem, are probably needed if a sane run time is desired
require 'rubygems'
require 'classifier'

lsi = Classifier::LSI.new :auto_rebuild => false
eps = Episode.find(:all)
podcast_lookup = {}
# LOL. {} syntax for multiline block and do;end for one line;
eps.each{|ep|
  podcast_lookup[ep.id] = ep.podcast.id
  lsi.add_item(ep.id) do; ep.summary || ""; end
}

lsi.build_index

puts eps.collect{ |ep|
  lsi.find_related(ep.id,10).join(", ")
}.join("\n")
