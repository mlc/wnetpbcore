class AddTemplateName < ActiveRecord::Migration
  def self.up
    add_column :instantiations, :template_name, :string, :null => true
    add_index :instantiations, :template_name
  end

  def self.down
    remove_column :instantiations, :template_name
  end
end
