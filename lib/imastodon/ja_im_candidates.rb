# frozen_string_literal: true

# ja-IM で言い換える候補（en と ja にあって ja-IM に無いキー）を探す
class JaImCandidates
  # ja の語 => ja-IM での言い換え。既存の ja-IM で全面的に言い換えている語だけを載せる
  # 「通知」「フォロー」は言い換え済みのキーでもそのまま残っているので載せない
  TERMS = {
    '投稿' => 'あふぅ',
    'ブースト' => 'わかるわ',
    'お気に入りタグ' => 'スウィーティー☆なタグ',
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

  # config/locales に置くと Rails と i18n-tasks にロケールとして読まれるので、ここに置く
  IGNORE_FILE = File.expand_path('ja_im_candidates.ignore.yml', __dir__)

  def self.load_ignored(path = IGNORE_FILE)
    data = YAML.load_file(path) || {}

    { json: (data['json'] || {}).keys, yml: (data['yml'] || {}).keys }
  end

  def self.load_json(dir)
    LOCALES.transform_values { |locale| JSON.parse(File.read(File.join(dir, "#{locale}.json"))) }
  end

  # Rails の I18n と同じく <locale>.yml と *.<locale>.yml（simple_form など）をまとめて読む
  def self.load_yml(dir)
    LOCALES.transform_values do |locale|
      paths = [File.join(dir, "#{locale}.yml"), *Dir[File.join(dir, '**', "*.#{locale}.yml")]]

      paths.select { |path| File.exist?(path) }.each_with_object({}) do |path, messages|
        messages.merge!(flatten(YAML.load_file(path).fetch(locale, {})))
      end
    end
  end

  def self.flatten(hash, prefix = nil)
    hash.each_with_object({}) do |(key, value), result|
      path = [prefix, key].compact.join('.')
      value.is_a?(Hash) ? result.merge!(flatten(value, path)) : result[path] = value
    end
  end
  private_class_method :flatten

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
    # bin から Rails 抜きで使うので ActiveSupport の index_with は使わない
    TERMS.keys.to_h do |term|
      keys = @ja_messages.select { |key, message| @en_messages.key?(key) && message.to_s.include?(term) }.keys

      [term, {
        total: keys.size,
        overridden: keys.count { |key| @ja_im_messages.key?(key) },
        ignored: keys.count { |key| !@ja_im_messages.key?(key) && @ignored_keys.include?(key) },
      }]
    end
  end

  private

  def suggest(message)
    TERMS.reduce(message) { |result, (term, replacement)| result.gsub(term, replacement) }
  end
end
