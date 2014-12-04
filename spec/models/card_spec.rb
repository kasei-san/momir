require 'rails_helper'

RSpec.describe Card, :type => :model do
  describe '#parse' do
    subject { Card.parse(text) }

    let(:text){ <<-EOS }
　英語名：Abattoir Ghoul
日本語名：肉切り屋のグール（にくきりやのぐーる）
　コスト：(３)(黒)
　タイプ：クリーチャー --- ゾンビ(Zombie)
先制攻撃#{0x0D.chr}
このターン、肉切り屋のグールによってダメージを与えられたクリーチャーが１体死亡するたび、あなたはそのクリーチャーのタフネスに等しい点数のライフを得る。
　Ｐ／Ｔ：3/2
イラスト：Volkan Baga
　セット：Innistrad
　稀少度：アンコモン
    EOS

    it { expect(subject.name).to eq('Abattoir Ghoul') }
    it { expect(subject.japanese_name).to eq('肉切り屋のグール') }
    it { expect(subject.mana_cost).to eq('(3)(黒)') }
    it { expect(subject.card_type).to eq('クリーチャー --- ゾンビ(Zombie)') }
    it { expect(subject.text).to eq(<<-EOS.strip) }
先制攻撃
このターン、肉切り屋のグールによってダメージを与えられたクリーチャーが１体死亡するたび、あなたはそのクリーチャーのタフネスに等しい点数のライフを得る。
    EOS
    it { expect(subject.power_toughness).to eq('3/2') }
    it { expect(subject.converted_mana_cost).to eq(4) }

    it { expect(subject.other_name).to be_blank }
    it { expect(subject.other_japanese_name).to be_blank }
    it { expect(subject.other_card_type).to be_blank }
    it { expect(subject.other_text).to be_blank }

    context '混成マナコスト' do
      let(:text){ <<-EOS }
　英語名：Azorius Guildmage
日本語名：アゾリウスのギルド魔道士（あぞりうすのぎるどまどうし）
　コスト：(白/青)(白/青)
　タイプ：クリーチャー --- ヴィダルケン(Vedalken)・ウィザード(Wizard)
（(白/青)は(白)でも(青)でも支払うことができる。）#{0x0D.chr}
(２)(白)：クリーチャー１体を対象とし、それをタップする。#{0x0D.chr}
(２)(青)：起動型能力１つを対象とし、それを打ち消す。（マナ能力は対象にできない。）
　Ｐ／Ｔ：2/2
イラスト：Christopher Moeller
　セット：Dissension
　稀少度：アンコモン
      EOS

      it { expect(subject.mana_cost).to eq('(白/青)(白/青)') }
      it { expect(subject.converted_mana_cost).to eq(2) }
    end

    context '反転カード' do
      let(:text){ <<-EOS }
　英語名：Student of Elements
日本語名：精霊の学び手（せいれいのまなびて）
　コスト：(１)(青)
　タイプ：クリーチャー --- 人間(Human)・ウィザード(Wizard)
精霊の学び手が飛行を持っているとき、精霊の学び手を反転する。
　Ｐ／Ｔ：1/1
イラスト：Ittoku
　英語名：Tobita, Master of Winds
日本語名：風の達人、鳶太（かぜのたつじんとびた）
　コスト：(１)(青)
　タイプ：伝説のクリーチャー --- 人間(Human)・ウィザード(Wizard)
あなたがコントロールするクリーチャーは飛行を持つ。
　Ｐ／Ｔ：3/3
イラスト：Ittoku
　セット：Champions of Kamigawa
　稀少度：アンコモン
      EOS

      it { expect(subject.name).to eq('Student of Elements') }
      it { expect(subject.japanese_name).to eq('精霊の学び手') }
      it { expect(subject.mana_cost).to eq('(1)(青)') }
      it { expect(subject.card_type).to eq('クリーチャー --- 人間(Human)・ウィザード(Wizard)') }
      it { expect(subject.text).to eq(<<-EOS.strip) }
精霊の学び手が飛行を持っているとき、精霊の学び手を反転する。
      EOS
      it { expect(subject.power_toughness).to eq('1/1') }
      it { expect(subject.converted_mana_cost).to eq(2) }

      it { expect(subject.other_name).to eq('Tobita, Master of Winds') }
      it { expect(subject.other_japanese_name).to eq('風の達人、鳶太') }
      it { expect(subject.other_card_type).to eq('伝説のクリーチャー --- 人間(Human)・ウィザード(Wizard)') }
      it { expect(subject.other_text).to eq(<<-EOS.strip) }
あなたがコントロールするクリーチャーは飛行を持つ。
      EOS
      it { expect(subject.other_power_toughness).to eq('3/3') }
    end

    it '変身カード'
  end
end
