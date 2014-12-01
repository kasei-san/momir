class Card < ActiveRecord::Base
  def self.parse(text)

    parse_text = text.dup
    parse_text.gsub!(/^　タイプ：.*$\n/, '\&テキスト：')      # テキストだけヘッダが無いので追加
    parse_text.gsub!("　", '').gsub!(/([^\r])\n/, "\\1\n\n") # テキストだけ\r\nで改行されている
    parse_text.gsub!(/^(イラスト|セット|稀少度).*$\n\n/, '') # 変身・反転カードのときめんどいので削除

    current_flg = true
    parse_text.split("\n\n").map{|str| str.split('：', 2)}.each_slice(6).map(&:to_h).map do |hash|
      hash['日本語名'].sub!(/（.*$/, '')
      hash['テキスト'].sub!(/\r/, '')
      hash['コスト'].tr!('０-９', '0-9')

      if current_flg
        converted_mana_cost = hash['コスト'].scan(/\([^\)]+\)/).map{|v| v.sub!(/\(([^\)]+)\)/, '\1')}.inject(0) do |result, cost|
          result + (cost =~ /\A\d+\z/ ? cost.to_i : 1)
        end
        current_flg = false
      else
        converted_mana_cost = -1
      end

      Card.new({
        name:                 hash['英語名'],
        japanese_name:        hash['日本語名'],
        mana_cost:            hash['コスト'],
        card_type:            hash['タイプ'],
        text:                 hash['テキスト'],
        power_toughness:      hash['Ｐ／Ｔ'],
        converted_mana_cost: converted_mana_cost
      })
    end
  end
end
