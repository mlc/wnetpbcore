class CreateBorrowings < ActiveRecord::Migration
  def self.up
    create_table :borrowings do |t|
      t.integer :instantiation_id, :null => false
      t.string :person, :null => false
      t.string :department
      t.timestamp :borrowed
      t.timestamp :returned
    end
    add_index :borrowings, :instantiation_id
  end

  def self.down
    drop_table :borrowings
  end
end
