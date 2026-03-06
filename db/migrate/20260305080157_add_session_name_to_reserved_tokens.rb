class AddSessionNameToReservedTokens < ActiveRecord::Migration[8.1]
  def change
    add_column :reserved_tokens, :session_name, :string
  end
end
