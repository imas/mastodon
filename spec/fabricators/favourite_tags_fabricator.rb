# frozen_string_literal: true

Fabricator(:favourite_tag) do
  account
  name 'test'
  visibility 0
  order 0
end
