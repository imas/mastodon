# frozen_string_literal: true

# ja-IM で言い換える候補（en と ja にあって ja-IM に無いキー）を探す
class JaImCandidates
  # ja の語 => ja-IM での言い換え。既存の ja-IM で全面的に言い換えている語だけを載せる
  # 「通知」「フォロー」は言い換え済みのキーでもそのまま残っているので載せない
  TERMS = {
    '投稿' => 'あふぅ',
    'ブースト' => 'わかるわ',
    'お気に入り' => 'ティン',
    '返信' => 'Re:あふぅ',
    'メンション' => 'Re:あふぅ',
    'ミュート' => 'だまっとけ☆',
    '閲覧注意' => '早苗さんに見つからない',
    'ホームタイムライン' => 'オフィス',
    'ホーム' => 'オフィス',
    'ローカルタイムライン' => '楽屋',
    '連合タイムライン' => 'ライブステージ',
    'ピン留め' => '固定',
  }.sort_by { |term, _| -term.length }.to_h.freeze

  Candidate = Struct.new(:key, :ja, :suggestion)

  LOCALES = { en_messages: 'en', ja_messages: 'ja', ja_im_messages: 'ja-IM' }.freeze

  def self.load_json(dir)
    LOCALES.transform_values { |locale| JSON.parse(File.read(File.join(dir, "#{locale}.json"))) }
  end

  def initialize(en_messages:, ja_messages:, ja_im_messages:, ignored_keys: [])
    @en_messages = en_messages
    @ja_messages = ja_messages
    @ja_im_messages = ja_im_messages
    @ignored_keys = ignored_keys
  end

  def candidates
    @ja_messages.filter_map do |key, message|
      next unless @en_messages.key?(key)
      next if @ja_im_messages.key?(key) || @ignored_keys.include?(key)
      next unless TERMS.keys.any? { |term| message.to_s.include?(term) }

      Candidate.new(key, message, suggest(message))
    end
  end

  def coverage
    TERMS.keys.index_with do |term|
      keys = @ja_messages.select { |key, message| @en_messages.key?(key) && message.to_s.include?(term) }.keys

      {
        total: keys.size,
        overridden: keys.count { |key| @ja_im_messages.key?(key) },
        ignored: keys.count { |key| !@ja_im_messages.key?(key) && @ignored_keys.include?(key) },
      }
    end
  end

  private

  def suggest(message)
    TERMS.reduce(message) { |result, (term, replacement)| result.gsub(term, replacement) }
  end
end
