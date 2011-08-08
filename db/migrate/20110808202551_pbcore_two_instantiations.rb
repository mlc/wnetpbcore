class PbcoreTwoInstantiations < ActiveRecord::Migration
  FIELDS = {
    :instantiations => ["startTime", "endTime", "timeAnnotation"],
    :annotations => ["annotationType", "ref"]
  }

  def self.up
    FIELDS.each do |table, cols|
      cols.each do |col|
        add_column table, col.underscore.to_sym, :text, :default => nil, :null => true
      end
    end
 
    create_table :instantiation_dates do |t|
      t.integer :instantiation_id, :null => false
      t.integer :instantiation_date_type_id
      t.text :date
      t.integer  "creator_id"
      t.integer  "updater_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    create_table :instantiation_date_types do |t|
      t.string  "name"
      t.boolean "visible", :default => false, :null => false
    end

    available_start = InstantiationDateType.create(:name => "Available Start", :visible => true)
    available_end = InstantiationDateType.create(:name => "Available End", :visible => true)
    result = execute("SELECT instantiation_id, date_available_start, date_available_end FROM date_availables")
    result.each do |row|
      if (!row[1].nil? && row[1] != "")
        InstantiationDate.create(:instantiation_id => row[0], :instantiation_date_type => available_start, :date => row[1])
      end
      if (!row[2].nil? && row[2] != "")
        InstantiationDate.create(:instantiation_id => row[0], :instantiation_date_type => available_end, :date => row[2])
      end
    end
    result.free

    drop_table :date_availables

    created = InstantiationDateType.create(:name => "Created", :visible => true)
    issued = InstantiationDateType.create(:name => "Issued", :visible => true)
    result = execute("SELECT id, date_created, date_issued FROM instantiations")
    result.each do |row|
      if (!row[1].nil? && row[1] != "")
        InstantiationDate.create(:instantiation_id => row[0], :instantiation_date_type => created, :date => row[1])
      end
      if (!row[2].nil? && row[2] != "")
        InstantiationDate.create(:instantiation_id => row[0], :instantiation_date_type => issued, :date => row[2])
      end
    end
    result.free

    remove_column :instantiations, :date_created
    remove_column :instantiations, :date_issued
  end

  def self.down
    raise "once you go forward, you can't go back."
  end
end
