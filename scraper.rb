require 'scraperwiki'
require 'mechanize'
# require 'pry'

class Scraper

  CATEGORIES = {
    '101' => 'supermarket',              # スーパー
    '102' => 'liquor_convenience',    # 食品･菓子･飲料･酒･日用品･コンビニ
    '107' => 'drug',                          # ドラッグストア
    '103' => 'furniture',                    # 家具･ホームセンター
    '109' => 'electronics',                # 家電店
    '105' => 'department',               # ショッピングセンター･百貨店
    '104' => 'fashon',                     # ファッション
    '108' => 'kids',                         # キッズ･ベビー･おもちゃ
    '106' => 'grasses',                   # 眼鏡･コンタクト･ケア用品
    '115' => 'car',                          # 車･バイク
    '116' => 'sports',                      # スポーツ用品･自転車
    '110' => 'mobile',                     # 携帯･通信･家電
    '128' => 'ec',                           # 通販･ネットショップ
    '111' => 'flower',                       # 花･ギフト･手芸
    '118' => 'bookstore',                 # 本･雑誌･音楽･DVD･映画･ゲーム
    '125' => 'reuse',                       # リサイクル
    '117' => 'beauty',                      # ヘルス＆ビューティ･フィットネス
    '124' => 'manshon',                   # マンション･戸建･リフォーム･レンタル収納
    '121' => 'travel',                        # 旅行･ホテル･リゾート
    '122' => 'calture',                      # 学習塾･カルチャー･教育･教習所
    '112' => 'delively',                     # レストラン･デリバリー･外食
    '114' => 'photo',                         # フォト･プリントサービス
    '119' => 'amusement',                # アミューズメント
    '123' => 'insurance',                   # 保険･共済･金融
    '113' => 'event',                         # 冠婚葬祭･イベント
    '129' => 'coupon',                      # プレゼントキャンペーン･クーポン
    '126' => 'media',                        # TV局・新聞社・フリーペーパー・その他
    '131' => 'life',                            # 生活・くらし
    '132' => 'party',                         # 政党・政治
    '130' => 'post_office',                # 郵便局
    '127' => 'notice',                       # Shufoo!お知らせ
  }.freeze

  def self.run
    date = Date.today.to_s
    agent = Mechanize.new

    category_rows = []
    shop_rows = []
    CATEGORIES.each do |id, category|
      page = agent.get(self.category_base_url % id)
      h1 = page.at('h1')
      raise "not found h1 (id: #{id}, category: #{category})" unless h1
      count = h1.inner_text.match(/（(\d+)件）/)  ? $1.to_i : -1
      category_rows << { 'date' => date, 'category' => category, 'count' => count }

      if count > 0
        shops = page.search('.list-result-02 a')
        shops.each do |shop|
          id = shop[:href].match(/\/([0-9-]+)\/\z/)  ? $1.to_i : -1
          shop_rows << { 'date' => date, 'category' => category, 'id' => id, 'name' => shop.inner_text }
        end
      end

      sleep rand
    end

    ScraperWiki.save_sqlite(['date', 'category'], category_rows, 'categories')
    ScraperWiki.save_sqlite(['date', 'category', 'id'], shop_rows, 'category_shops')
  end

  def self.category_base_url
    @category_base_url ||= ENV.fetch('MORPH_CATEGORY_BASE_URL')
  end
end

Scraper.run
