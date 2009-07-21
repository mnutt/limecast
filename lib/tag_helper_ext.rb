# Note: this is in Rails trunk (http://github.com/rails/rails/commit/51d7b3070c68492f5376c19d24d8e5a2d746d7ea)
module ActionView
  module Helpers
    module TagHelper
      BOOLEAN_ATTRIBUTES = %w(disabled readonly multiple checked autobuffer
                             autoplay controls loop).to_set
      BOOLEAN_ATTRIBUTES.merge(BOOLEAN_ATTRIBUTES.map {|attr| attr.to_sym })
    end
  end
end