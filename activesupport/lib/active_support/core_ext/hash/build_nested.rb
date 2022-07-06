# frozen_string_literal: true

class Hash
  # Builds a new hash that's easy to merge with deep_merge
  #
  #   h1 = Hash.build_nested(:conferences, :tracks, :sessions, :keynote, presenter: '@tenderlove', topic: 'hotwire')
  #   # => { conferences: { tracks: { sessions: { keynote: { presenter: "@tenderlove", :topic=>"hotwire" } } } } }
  #
  #   h1.deep_merge(h2) # => { a: false, b: { c: [1, 2, 3], x: [3, 4, 5] } }
  #
  # use build_nested with deep_merge to make modifications deep in the hash structure:
  #
  #   h1 = { a: { b: { c: { c1: 100 } } } }
  #   h1.deep_merge(Hash.build_nested(:a, :b, :c, c2: 200, c3: 300))
  #   # => { a: { b: { c: { c1: 100, c2: 200, c3: 300 } } } }
  def self.build_nested(*args, **kwargs)
    args.reverse.reduce(Hash.new.merge(**kwargs)) do |hash, arg|
      { arg => hash }
    end
  end
end
