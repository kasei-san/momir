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
(青),(Ｔ) : クリーチャー１体を対象とする。それはターン終了時まで飛行を得る。
(黒),(Ｔ) : クリーチャー１体を対象とする。それはターン終了時まで-2/-0の修整を受ける。
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

    context 'LvUp' do
      let(:text){ <<-EOS }
　英語名：Beastbreaker of Bala Ged
日本語名：バーラ・ゲドの獣壊し（ばーらげどのけものこわし）
　コスト：(１)(緑)
　タイプ：クリーチャー --- 人間(Human)・戦士(Warrior)
Ｌｖアップ(２)(緑)（(２)(緑)：この上にＬｖ(level)カウンターを１個置く。Ｌｖアップはソーサリーとしてのみ行う。）
　Ｐ／Ｔ：2/2
Lv1-3：

　Ｐ／Ｔ：4/4
Lv4+：
トランプル
　Ｐ／Ｔ：6/6
イラスト：Karl Kopinski
　セット：Rise of the Eldrazi
　稀少度：アンコモン
      EOS

      it { expect(subject.name).to eq('Beastbreaker of Bala Ged') }
      it { expect(subject.japanese_name).to eq('バーラ・ゲドの獣壊し') }
      it { expect(subject.mana_cost).to eq('(1)(緑)') }
      it { expect(subject.card_type).to eq('クリーチャー --- 人間(Human)・戦士(Warrior)') }
      it { expect(subject.text).to eq(<<-EOS.strip) }
Ｌｖアップ(２)(緑)（(２)(緑) : この上にＬｖ(level)カウンターを１個置く。Ｌｖアップはソーサリーとしてのみ行う。）
Ｐ／Ｔ : 2/2
Lv1-3 : 
Ｐ／Ｔ : 4/4
Lv4+ : 
トランプル
      EOS
      it { expect(subject.power_toughness).to eq('6/6') }
      it { expect(subject.converted_mana_cost).to eq(2) }

      it { expect(subject.other_name).to be_blank }
      it { expect(subject.other_japanese_name).to be_blank }
      it { expect(subject.other_card_type).to be_blank }
      it { expect(subject.other_text).to be_blank }
      it { expect(subject.other_power_toughness).to be_blank }
    end

    context '色指標' do
      let(:text){ <<-EOS }
　英語名：Crimson Kobolds
日本語名：真紅のコボルド
　コスト：(０)
　色指標：〔赤〕
　タイプ：クリーチャー --- コボルド(Kobold)

　Ｐ／Ｔ：0/1
イラスト：Anson Maddocks
　セット：Legends
　稀少度：コモン2
      EOS

      it { expect(subject.name).to eq('Crimson Kobolds') }
      it { expect(subject.japanese_name).to eq('真紅のコボルド') }
      it { expect(subject.mana_cost).to eq('(0)') }
      it { expect(subject.card_type).to eq('クリーチャー --- コボルド(Kobold)') }
      it { expect(subject.text).to eq(<<-EOS.strip) }
色指標 : 〔赤〕
      EOS
      it { expect(subject.power_toughness).to eq('0/1') }
      it { expect(subject.converted_mana_cost).to eq(0) }

      it { expect(subject.other_name).to be_blank }
      it { expect(subject.other_japanese_name).to be_blank }
      it { expect(subject.other_card_type).to be_blank }
      it { expect(subject.other_text).to be_blank }
      it { expect(subject.other_power_toughness).to be_blank }
    end

    context '変身カード' do
      let(:text){ <<-EOS }
　英語名：Daybreak Ranger
日本語名：夜明けのレインジャー（よあけのれいんじゃー）
　コスト：(２)(緑)
　タイプ：クリーチャー --- 人間(Human)・射手(Archer)・狼男(Werewolf)
(Ｔ)：飛行を持つクリーチャー１体を対象とする。夜明けのレインジャーはそれに２点のダメージを与える。
各アップキープの開始時に、直前のターンに呪文が唱えられていなかった場合、夜明けのレインジャーを変身させる。
　Ｐ／Ｔ：2/2
イラスト：Steve Prescott
　英語名：Nightfall Predator
日本語名：黄昏の捕食者（たそがれのほしょくしゃ）
　コスト：
　色指標：〔緑〕
　タイプ：クリーチャー --- 狼男(Werewolf)
(赤),(Ｔ)：クリーチャー１体を対象とする。黄昏の捕食者はそれと格闘を行う。（それぞれはもう一方に自身のパワーに等しい点数のダメージを与える。）
各アップキープの開始時に、直前のターンにプレイヤー１人が２つ以上の呪文を唱えていた場合、黄昏の捕食者を変身させる。
　Ｐ／Ｔ：4/4
イラスト：Steve Prescott
　セット：Innistrad
　稀少度：レア
      EOS

      it { expect(subject.name).to eq('Daybreak Ranger') }
      it { expect(subject.japanese_name).to eq('夜明けのレインジャー') }
      it { expect(subject.mana_cost).to eq('(2)(緑)') }
      it { expect(subject.card_type).to eq('クリーチャー --- 人間(Human)・射手(Archer)・狼男(Werewolf)') }
      it { expect(subject.text).to eq(<<-EOS.strip) }
(Ｔ) : 飛行を持つクリーチャー１体を対象とする。夜明けのレインジャーはそれに２点のダメージを与える。
各アップキープの開始時に、直前のターンに呪文が唱えられていなかった場合、夜明けのレインジャーを変身させる。
      EOS
      it { expect(subject.power_toughness).to eq('2/2') }
      it { expect(subject.converted_mana_cost).to eq(3) }

      it { expect(subject.other_name).to eq('Nightfall Predator') }
      it { expect(subject.other_japanese_name).to eq('黄昏の捕食者') }
      it { expect(subject.other_card_type).to eq('クリーチャー --- 狼男(Werewolf)') }
      it { expect(subject.other_text).to eq(<<-EOS.strip) }
色指標 : 〔緑〕
(赤),(Ｔ) : クリーチャー１体を対象とする。黄昏の捕食者はそれと格闘を行う。（それぞれはもう一方に自身のパワーに等しい点数のダメージを与える。）
各アップキープの開始時に、直前のターンにプレイヤー１人が２つ以上の呪文を唱えていた場合、黄昏の捕食者を変身させる。
      EOS
      it { expect(subject.other_power_toughness).to eq('4/4') }
    end

    context '変身カード(エンチャント) ' do
      let(:text){ <<-EOS }
　英語名：Soul Seizer
日本語名：魂を捕えるもの（たましいをとらえるもの）
　コスト：(３)(青)(青)
　タイプ：クリーチャー --- スピリット(Spirit)
飛行
魂を捕えるものがプレイヤー１人に戦闘ダメージを与えたとき、そのプレイヤーがコントロールするクリーチャー１体を対象とする。あなたは魂を捕えるものを変身させてもよい。そうした場合、あなたはそれをそのクリーチャーにつける。
　Ｐ／Ｔ：1/3
イラスト：Lucas Graciano
　英語名：Ghastly Haunting
日本語名：恐ろしい憑依（おそろしいひょうい）
　コスト：
　色指標：〔青〕
　タイプ：エンチャント --- オーラ(Aura)
エンチャント（クリーチャー）
あなたはエンチャントされているクリーチャーをコントロールする。
イラスト：Lucas Graciano
　セット：Dark Ascension
　稀少度：アンコモン
      EOS

      it { expect(subject.name).to eq('Soul Seizer') }
      it { expect(subject.japanese_name).to eq('魂を捕えるもの') }
      it { expect(subject.mana_cost).to eq('(3)(青)(青)') }
      it { expect(subject.card_type).to eq('クリーチャー --- スピリット(Spirit)') }
      it { expect(subject.text).to eq(<<-EOS.strip) }
飛行
魂を捕えるものがプレイヤー１人に戦闘ダメージを与えたとき、そのプレイヤーがコントロールするクリーチャー１体を対象とする。あなたは魂を捕えるものを変身させてもよい。そうした場合、あなたはそれをそのクリーチャーにつける。
      EOS
      it { expect(subject.power_toughness).to eq('1/3') }
      it { expect(subject.converted_mana_cost).to eq(5) }

      it { expect(subject.other_name).to eq('Ghastly Haunting') }
      it { expect(subject.other_japanese_name).to eq('恐ろしい憑依') }
      it { expect(subject.other_card_type).to eq('エンチャント --- オーラ(Aura)') }
      it { expect(subject.other_text).to eq(<<-EOS.strip) }
色指標 : 〔青〕
エンチャント（クリーチャー）
あなたはエンチャントされているクリーチャーをコントロールする。
      EOS
      it { expect(subject.other_power_toughness).to be_blank }
    end
  end
end
