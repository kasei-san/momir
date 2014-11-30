class CreateCards < ActiveRecord::Migration
  def change
    create_table :cards do |t|
      t.string :name
      t.string :japanese_name
      t.string :mana_cost
      t.string :type
      t.text :text
      t.string :power_toughness
      t.integer :converted_mana_cost

      t.timestamps
    end
    add_index :cards, :converted_mana_cost
  end
end
