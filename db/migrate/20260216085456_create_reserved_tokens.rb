class CreateReservedTokens < ActiveRecord::Migration[8.1]
  def change
    create_table :reserved_tokens do |t|
      t.integer :organization_id
      t.integer :token_number
      t.timestamps
    end
  end
end
