# frozen_string_literal: true

namespace :imastodon do
  task migrate_favourite_tags: :environment do
    FavouriteTag.all.includes(:tag).find_in_batches do |favourite_tags|
      Rails.logger.info("imastodon:migrate_favourite_tags: #{favourite_tags.first.id}..#{favourite_tags.last.id}")
      favourite_tags.each(&:migrate_tag_name!)
    end
  end
end
