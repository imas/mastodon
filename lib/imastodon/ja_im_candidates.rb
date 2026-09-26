# frozen_string_literal: true

# ja-IM で言い換える候補（en と ja にあって ja-IM に無いキー）を探す
class JaImCandidates
  # ja の語 => ja-IM での言い換え
  TERMS = {
    '投稿' => 'あふぅ',
  }.freeze

  Candidate = Struct.new(:key, :ja)

  def initialize(en_messages:, ja_messages:, ja_im_messages:, ignored_keys: [])
    @en_messages = en_messages
    @ja_messages = ja_messages
    @ja_im_messages = ja_im_messages
    @ignored_keys = ignored_keys
  end

  def candidates
    @ja_messages.filter_map do |key, message|
      next if @ja_im_messages.key?(key)
      next unless TERMS.keys.any? { |term| message.to_s.include?(term) }

      Candidate.new(key, message)
    end
  end
end
