# frozen_string_literal: true

# ja-IM で言い換える候補（en と ja にあって ja-IM に無いキー）を探す
class JaImCandidates
  def initialize(en_messages:, ja_messages:, ja_im_messages:, ignored_keys: [])
    @en_messages = en_messages
    @ja_messages = ja_messages
    @ja_im_messages = ja_im_messages
    @ignored_keys = ignored_keys
  end
end
