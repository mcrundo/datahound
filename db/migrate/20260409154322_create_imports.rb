class CreateImports < ActiveRecord::Migration[8.1]
  def change
    create_table :imports do |t|
      t.string :status, null: false, default: "pending"
      t.timestamps
    end
  end
end
