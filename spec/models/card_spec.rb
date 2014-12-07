require 'rails_helper'

RSpec.describe Card, :type => :model do

  shared_examples_for 'abattoir_ghoul' do
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
  end

  shared_examples_for 'alaborn_trooper' do
    it { expect(subject.name).to eq('Alaborn Trooper') }
    it { expect(subject.japanese_name).to eq('アラボーンの強兵') }
    it { expect(subject.mana_cost).to eq('(2)(白)') }
    it { expect(subject.card_type).to eq('クリーチャー --- 人間(Human)・兵士(Soldier)') }
    it { expect(subject.text).to be_blank }
    it { expect(subject.power_toughness).to eq('2/3') }
    it { expect(subject.converted_mana_cost).to eq(3) }

    it { expect(subject.other_name).to be_blank }
    it { expect(subject.other_japanese_name).to be_blank }
    it { expect(subject.other_card_type).to be_blank }
    it { expect(subject.other_text).to be_blank }
  end

  shared_examples_for 'ana_disciple' do
    it { expect(subject.name).to eq('Ana Disciple') }
    it { expect(subject.japanese_name).to eq('アナの信奉者') }
    it { expect(subject.mana_cost).to eq('(緑)') }
    it { expect(subject.card_type).to eq('クリーチャー --- 人間(Human)・ウィザード(Wizard)') }
    it { expect(subject.text).to eq(<<-EOS.strip) }
(青),(Ｔ)：クリーチャー１体を対象とする。それはターン終了時まで飛行を得る。
(黒),(Ｔ)：クリーチャー１体を対象とする。それはターン終了時まで-2/-0の修整を受ける。
    EOS
    it { expect(subject.power_toughness).to eq('1/1') }
    it { expect(subject.converted_mana_cost).to eq(1) }

    it { expect(subject.other_name).to be_blank }
    it { expect(subject.other_japanese_name).to be_blank }
    it { expect(subject.other_card_type).to be_blank }
    it { expect(subject.other_text).to be_blank }
  end

  describe '#import' do
    let(:path) { File.join(*%W[#{File.dirname(__FILE__)} .. data card_data.txt]) }
    it { expect { Card.import(path) }.to change(Card, :count).from(0).to(3) }

    describe 'check card_data' do
      before { Card.import(path) }

      context 'Abattoir Ghoul' do
        subject { Card.find_by_name('Abattoir Ghoul') }
        it_should_behave_like 'abattoir_ghoul'
      end

      context 'Alaborn Trooper(vanilla)' do
        subject { Card.find_by_name('Alaborn Trooper') }
        it_should_behave_like 'alaborn_trooper'
      end
    end
  end

  describe '#parse' do
    subject { Card.parse(text) }

    context 'abattoir_ghoul' do
      let(:text){ (<<-EOS).strip }
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

      it_should_behave_like 'abattoir_ghoul'
    end

    context 'テキストの改行に \r が無い' do
      let(:text){ (<<-EOS).strip }
　英語名：Ana Disciple
日本語名：アナの信奉者（あなのしんぽうしゃ）
　コスト：(緑)
　タイプ：クリーチャー --- 人間(Human)・ウィザード(Wizard)
(青),(Ｔ)：クリーチャー１体を対象とする。それはターン終了時まで飛行を得る。
(黒),(Ｔ)：クリーチャー１体を対象とする。それはターン終了時まで-2/-0の修整を受ける。
　Ｐ／Ｔ：1/1
イラスト：Darrell Riche
　セット：Apocalypse
　稀少度：コモン
      EOS

      it_should_behave_like 'ana_disciple'
    end

    context 'vanilla' do
      let(:text){ (<<-EOS).strip }
　英語名：Alaborn Trooper
日本語名：アラボーンの強兵（あらぼーんのきょうへい）
　コスト：(２)(白)
　タイプ：クリーチャー --- 人間(Human)・兵士(Soldier)

　Ｐ／Ｔ：2/3
イラスト：Lubov
　セット：Portal Second Age
　稀少度：コモン
      EOS

      it_should_behave_like 'alaborn_trooper'
    end

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
　英語名：Akki Lavarunner
日本語名：悪忌の溶岩走り（あっきのようがんばしり）
　コスト：(３)(赤)
　タイプ：クリーチャー --- ゴブリン(Goblin)・戦士(Warrior)
速攻
悪忌の溶岩走りが対戦相手にダメージを与えるたび、これを反転する。
　Ｐ／Ｔ：1/1
イラスト：Matt Cavotta
　英語名：Tok-Tok, Volcano Born
日本語名：溶岩生まれのトクトク（ようがんうまれのとくとく）
　コスト：(３)(赤)
　タイプ：伝説のクリーチャー --- ゴブリン(Goblin)・シャーマン(Shaman)
プロテクション（赤）
赤の発生源１つがプレイヤーにダメージを与える場合、代わりにそれはそのダメージに１加えた点数だけダメージを与える。
　Ｐ／Ｔ：2/2
イラスト：Matt Cavotta
　セット：Champions of Kamigawa
　稀少度：レア
      EOS

      it { expect(subject.name).to eq('Akki Lavarunner') }
      it { expect(subject.japanese_name).to eq('悪忌の溶岩走り') }
      it { expect(subject.mana_cost).to eq('(3)(赤)') }
      it { expect(subject.card_type).to eq('クリーチャー --- ゴブリン(Goblin)・戦士(Warrior)') }
      it { expect(subject.text).to eq(<<-EOS.strip) }
速攻
悪忌の溶岩走りが対戦相手にダメージを与えるたび、これを反転する。
      EOS
      it { expect(subject.power_toughness).to eq('1/1') }
      it { expect(subject.converted_mana_cost).to eq(4) }

      it { expect(subject.other_name).to eq('Tok-Tok, Volcano Born') }
      it { expect(subject.other_japanese_name).to eq('溶岩生まれのトクトク') }
      it { expect(subject.other_card_type).to eq('伝説のクリーチャー --- ゴブリン(Goblin)・シャーマン(Shaman)') }
      it { expect(subject.other_text).to eq(<<-EOS.strip) }
プロテクション（赤）
赤の発生源１つがプレイヤーにダメージを与える場合、代わりにそれはそのダメージに１加えた点数だけダメージを与える。
      EOS
      it { expect(subject.other_power_toughness).to eq('2/2') }
    end


    context '反転カード(エンチャント)' do
      let(:text){ <<-EOS }
　英語名：Erayo, Soratami Ascendant
日本語名：上位の空民、エラヨウ（じょういのそらたみえらよう）
　コスト：(１)(青)
　タイプ：伝説のクリーチャー --- ムーンフォーク(Moonfolk)・モンク(Monk)
飛行
いずれかのターンに４つ目の呪文が唱えられるたび、上位の空民、エラヨウを反転する。
　Ｐ／Ｔ：1/1
イラスト：Matt Cavotta
　英語名：Erayo's Essence
日本語名：エラヨウの本質（えらようのほんしつ）
　コスト：(１)(青)
　タイプ：伝説のエンチャント
対戦相手１人が各ターンに最初に呪文を唱えるたび、その呪文を打ち消す。
イラスト：Matt Cavotta
　セット：Saviors of Kamigawa
　稀少度：レア
      EOS

      it { expect(subject.name).to eq('Erayo, Soratami Ascendant') }
      it { expect(subject.japanese_name).to eq('上位の空民、エラヨウ') }
      it { expect(subject.mana_cost).to eq('(1)(青)') }
      it { expect(subject.card_type).to eq('伝説のクリーチャー --- ムーンフォーク(Moonfolk)・モンク(Monk)') }
      it { expect(subject.text).to eq(<<-EOS.strip) }
飛行
いずれかのターンに４つ目の呪文が唱えられるたび、上位の空民、エラヨウを反転する。
      EOS
      it { expect(subject.power_toughness).to eq('1/1') }
      it { expect(subject.converted_mana_cost).to eq(2) }

      it { expect(subject.other_name).to eq("Erayo's Essence") }
      it { expect(subject.other_japanese_name).to eq('エラヨウの本質') }
      it { expect(subject.other_card_type).to eq('伝説のエンチャント') }
      it { expect(subject.other_text).to eq(<<-EOS.strip) }
対戦相手１人が各ターンに最初に呪文を唱えるたび、その呪文を打ち消す。
      EOS
      it { expect(subject.other_power_toughness).to be_blank }
    end

    it '変身カード'
  end
end
