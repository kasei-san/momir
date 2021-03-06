class Card < ActiveRecord::Base

  # How to use
  #   $ rails runner "Card.destroy; Card.import('./tmp/card_data.txt')"
  #
  def self.import(path)
    File.open(path) do |f|
      text = []
      while f.gets("\n\n\n") do
        Card.parse($_.strip).save!
      end
    end
  end

  def self.pickup(converted_mana_cost)
    cards = Card.where({:converted_mana_cost => converted_mana_cost})
    cards[rand(cards.count)]
  end

  def self.parse(text)
    return if text.blank?
    parse_text = text.dup.strip
    parse_text.gsub!(/(　タイプ：[^\n]+\n)/, '\&テキスト：') # テキストだけヘッダが無いので追加
    parse_text.gsub!(/^(　色指標：[^\n]+)\n(.*?テキスト：)/m ) do |text|
      "#{$2}#{$1}\n"
    end

    # テキスト内の改行を一旦削除
    if parse_text =~ /Ｌｖアップ/
      parse_text.gsub!(/テキスト：(.*)\n　Ｐ／Ｔ/m) do |text| # LvUp カードの場合、複数の P/T があるので、最長一致
        "テキスト：#{$1.gsub("\n", '@@@').gsub('：', ' : ')}\n　Ｐ／Ｔ"
      end
    else
      parse_text.gsub!(/テキスト：(.*?)\n(　Ｐ／Ｔ|イラスト)：/m) do |text| # テキスト内の改行を一旦削除
        text, key = $1, $2
        "テキスト：#{text.gsub("\n", '@@@').gsub('：', ' : ')}\n　#{key}："
      end
    end
    parse_text.gsub!("　", '').gsub!(/\r/, "") # テキストだけ\r\nで改行されている
    parse_text.gsub!(/^(イラスト|セット|稀少度).*($\n+|\z)/, '') # 変身・反転カードのときめんどいので削除

    card_data = parse_text.split("\n").map{|str| str.split('：', 2)}.each_slice(6).map(&:to_h)

    hash = card_data.first
    hash['日本語名'].sub!(/（.*$/, '')
    hash['テキスト'].gsub!(/@+/, "\n")
    hash['コスト'].tr!('０-９', '0-9')

    converted_mana_cost = hash['コスト'].scan(/\([^\)]+\)/).map{|v| v.sub!(/\(([^\)]+)\)/, '\1')}.inject(0) do |result, cost|
      result + (cost =~ /\A\d+\z/ ? cost.to_i : 1)
    end

    Card.new({
      name:                 hash['英語名'],
      japanese_name:        hash['日本語名'],
      mana_cost:            hash['コスト'],
      card_type:            hash['タイプ'],
      text:                 hash['テキスト'].strip,
      power_toughness:      hash['Ｐ／Ｔ'],
      converted_mana_cost: converted_mana_cost
    }).tap do |result|
      if card_data.size >= 2
        other = card_data[1]
        other['日本語名'].sub!(/（.*$/, '')
        other['テキスト'].gsub!(/@+/, "\n")
        other['コスト'].tr!('０-９', '0-9')

        result.other_name            = other['英語名']
        result.other_japanese_name   = other['日本語名']
        result.other_card_type       = other['タイプ']
        result.other_text            = other['テキスト'].strip
        result.other_power_toughness = other['Ｐ／Ｔ']
      end
    end
  end
end
