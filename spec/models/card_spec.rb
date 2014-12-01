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

    context '混成マナコスト' do
      let(:text){ <<-EOS }
　英語名：Azorius Guildmage
日本語名：アゾリウスのギルド魔道士（あぞりうすのぎるどまどうし）
　コスト：(白/青)(白/青)
　タイプ：クリーチャー --- ヴィダルケン(Vedalken)・ウィザード(Wizard)
（(白/青)は(白)でも(青)でも支払うことができる。）
(２)(白)：クリーチャー１体を対象とし、それをタップする。
(２)(青)：起動型能力１つを対象とし、それを打ち消す。（マナ能力は対象にできない。）
　Ｐ／Ｔ：2/2
イラスト：Christopher Moeller
　セット：Dissension
　稀少度：アンコモン
      EOS

      it { expect(subject.mana_cost).to eq('(白/青)(白/青)') }
      it { expect(subject.converted_mana_cost).to eq(2) }


    end
    it '混成(ローウィンの)マナコスト'
    it '変身カード'
    it '反転カード'
  end
end
