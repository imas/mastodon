# frozen_string_literal: true

module Friends
  module FavouriteTagsExtension
    extend ActiveSupport::Concern
    DEFAULT_TAGS = %w(
      デレラジ
      デレパ
      imas_mor
      millionradio
      sidem
    ).freeze

    included do
      has_many :favourite_tags
      after_create :add_default_favourite_tag, unless: -> { bot? }

      def add_default_favourite_tag
        DEFAULT_TAGS.each_with_index do |tag_name, i|
          favourite_tags.create!(visibility: 'unlisted', name: tag_name, order: (DEFAULT_TAGS.length - i))
        end
      end
    end
  end
end
