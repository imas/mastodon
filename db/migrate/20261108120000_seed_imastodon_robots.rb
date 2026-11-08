# frozen_string_literal: true

class SeedImastodonRobots < ActiveRecord::Migration[8.1]
  class Setting < ApplicationRecord; end

  def up
    Setting.reset_column_information

    Setting.upsert_all(
      [{ var: 'override_robots', value: true.to_yaml }],
      unique_by: index_exists?(:settings, [:thing_type, :thing_id, :var]) ? [:thing_type, :thing_id, :var] : :var
    )
  end

  def down; end
end
