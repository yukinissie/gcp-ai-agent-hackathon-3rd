class CreateIngredients < ActiveRecord::Migration[8.0]
  def change
    create_table :ingredients do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.json :llm_payload, null: false, default: {}
      t.json :ui_data, null: false, default: {}
      t.integer :total_interactions, null: false, default: 0
      t.decimal :diversity_score, precision: 5, scale: 3, null: false, default: 0.0

      t.timestamps
    end

    # 制約追加
    add_check_constraint :ingredients,
      "diversity_score >= 0.0 AND diversity_score <= 1.0",
      name: "check_diversity_score_range"

    add_check_constraint :ingredients,
      "total_interactions >= 0",
      name: "check_total_interactions_positive"

    # インデックス追加
    add_index :ingredients, :updated_at
    add_index :ingredients, :total_interactions
  end
end
