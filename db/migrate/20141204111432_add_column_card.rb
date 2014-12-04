class AddColumnCard < ActiveRecord::Migration
  def change
    add_column :cards, :other_name                , :string
    add_column :cards, :other_japanese_name       , :string
    add_column :cards, :other_card_type           , :string
    add_column :cards, :other_text                , :text
    add_column :cards, :other_power_toughness     , :string
  end
end
