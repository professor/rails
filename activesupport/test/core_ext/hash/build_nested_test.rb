# frozen_string_literal: true

# require_relative "../../abstract_unit"
require "active_support/core_ext/hash/build_nested"

class BuildNestedTest < ActiveSupport::TestCase
  test "build a deep nested hash structure" do
    actual = Hash.build_nested(:conference, :tracks, :sessions, :keynote, presenter: "@tenderlove", topic: "hotwire")
    expected = { conference: { tracks: { sessions: { keynote: { presenter: "@tenderlove", topic: "hotwire" } } } } }

    assert actual.equal?(expected)
  end
end
