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
  end
end
