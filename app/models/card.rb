class Card < ActiveRecord::Base
  def self.parse(text)
    hash = text.sub(/^　タイプ：.*$\n/, '\&テキスト：')     # テキストだけヘッダが無いので追加
            .gsub("　", '').gsub(/([^\r])\n/, "\\1\n\n") # テキストだけ\r\nで改行されている
            .split("\n\n").map{|str| str.split('：')}.to_h

    hash['日本語名'].sub!(/（.*$/, '')
    hash['テキスト'].sub!(/\r/, '')
    hash['コスト'].tr!('０-９', '0-9')

    Card.new({
      :name          => hash['英語名'],
      :japanese_name => hash['日本語名'],
      :mana_cost     => hash['コスト'],
      :card_type     => hash['タイプ'],
      :text => hash['テキスト'],
      :power_toughness => hash['Ｐ／Ｔ']

    })
  end
end
