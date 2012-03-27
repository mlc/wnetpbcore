class CreateAnnotationTypes < ActiveRecord::Migration
  def self.up
    create_table :annotation_types do |t|
      t.string :name
      t.boolean :visible, :default => true

      t.timestamps
    end
  end

  def self.down
    drop_table :annotation_types
  end
end
