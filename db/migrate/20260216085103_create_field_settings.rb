class CreateFieldSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :field_settings do |t|
      t.integer :organization_id
      t.string :field_name
      t.boolean :is_required
      t.timestamps
    end
  end
end
