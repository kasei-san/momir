require 'rails_helper'

RSpec.describe CardsController, :type => :controller do
  render_views
  describe "GET pickup" do
    before do
      Card.parse(<<-EOS).save!
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
    end

    context 'converted_mana_cost exist' do
      subject do
        get 'pickup', converted_mana_cost: 4
        response
      end

      it { is_expected.to be_success }
      it { expect(subject.headers['Content-Type']).to a_string_including('application/json') }

      describe 'returned JSON check' do
        subject do
          get 'pickup', converted_mana_cost: 4
          JSON.load(response.body).with_indifferent_access
        end

        it { expect(subject[:name]).to eq('Abattoir Ghoul') }
        it { expect(subject[:japanese_name]).to eq('肉切り屋のグール') }
        it { expect(subject[:mana_cost]).to eq('(3)(黒)') }
        it { expect(subject[:card_type]).to eq('クリーチャー --- ゾンビ(Zombie)') }
        it { expect(subject[:text]).to eq(<<-EOS.strip) }
先制攻撃
このターン、肉切り屋のグールによってダメージを与えられたクリーチャーが１体死亡するたび、あなたはそのクリーチャーのタフネスに等しい点数のライフを得る。
        EOS
        it { expect(subject[:power_toughness]).to eq('3/2') }
        it { expect(subject[:converted_mana_cost]).to eq(4) }
      end

      context 'No such converted_mana_cost' do
        subject do
          get 'pickup', converted_mana_cost: 9999
          response
        end
        it { is_expected.to be_success }
        it { expect(subject.body).to eq('null') }
      end

      context 'converted_mana_cost is nil' do
        subject do
          get 'pickup'
          response
        end
        it { is_expected.to be_success }
        it { p subject.body }
      end
    end
  end
end
