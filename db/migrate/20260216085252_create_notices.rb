class CreateNotices < ActiveRecord::Migration[8.1]
  def change
    create_table :notices do |t|
      t.integer :organization_id
      t.text :content
      t.integer :notice_type
      t.integer :status
      t.timestamps
    end
  end
end
