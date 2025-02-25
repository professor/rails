# frozen_string_literal: true

require "cases/helper"
require "models/comment"
require "models/post"

module ActiveRecord
  class WithTest < ActiveRecord::TestCase
    fixtures :comments
    fixtures :posts

    POSTS_WITH_TAGS = [1, 2, 7, 8, 9, 10, 11].freeze
    POSTS_WITH_COMMENTS = [1, 2, 4, 5, 7].freeze
    POSTS_WITH_MULTIPLE_COMMENTS = [1, 4, 5].freeze
    POSTS_WITH_TAGS_AND_COMMENTS = (POSTS_WITH_COMMENTS & POSTS_WITH_TAGS).sort.freeze
    POSTS_WITH_TAGS_AND_MULTIPLE_COMMENTS = (POSTS_WITH_MULTIPLE_COMMENTS & POSTS_WITH_TAGS).sort.freeze

    def test_with_when_hash_is_passed_as_an_argument
      relation = Post
        .with(posts_with_comments: Post.where("legacy_comments_count > 0"))
        .from("posts_with_comments AS posts")

      assert_equal POSTS_WITH_COMMENTS, relation.order(:id).pluck(:id)
    end

    def test_with_when_hash_with_multiple_elements_of_different_type_is_passed_as_an_argument
      cte_options = {
        posts_with_tags: Post.arel_table.project(Arel.star).where(Post.arel_table[:tags_count].gt(0)),
        posts_with_tags_and_comments: Arel.sql("SELECT * FROM posts_with_tags WHERE legacy_comments_count > 0"),
        "posts_with_tags_and_multiple_comments" => Post.where("legacy_comments_count > 1").from("posts_with_tags_and_comments AS posts")
      }
      relation = Post.with(cte_options).from("posts_with_tags_and_multiple_comments AS posts")

      assert_equal POSTS_WITH_TAGS_AND_MULTIPLE_COMMENTS, relation.order(:id).pluck(:id)
    end

    def test_multiple_with_calls
      relation = Post
        .with(posts_with_tags: Post.where("tags_count > 0"))
        .from("posts_with_tags_and_comments AS posts")
        .with(posts_with_tags_and_comments: Arel.sql("SELECT * FROM posts_with_tags WHERE legacy_comments_count > 0"))

      assert_equal POSTS_WITH_TAGS_AND_COMMENTS, relation.order(:id).pluck(:id)
    end

    def test_count_after_with_call
      relation = Post.with(posts_with_comments: Post.where("legacy_comments_count > 0"))

      assert_equal Post.count, relation.count
      assert_equal POSTS_WITH_COMMENTS.size, relation.from("posts_with_comments AS posts").count
      assert_equal POSTS_WITH_COMMENTS.size, relation.joins("JOIN posts_with_comments ON posts_with_comments.id = posts.id").count
    end

    def test_with_when_called_from_active_record_scope
      assert_equal POSTS_WITH_TAGS, Post.with_tags_cte.order(:id).pluck(:id)
    end

    def test_with_when_invalid_params_are_passed
      assert_raise(ArgumentError) { Post.with }
      assert_raise(ArgumentError) { Post.with(posts_with_tags: nil).load }
      assert_raise(ArgumentError) { Post.with(posts_with_tags: [Post.where("tags_count > 0")]).load }
    end
  end
end
