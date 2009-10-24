# A lot of PBCore fields are extensible picklists.
module Picklist

  module ClassMethods
    # avoid instantiating lots and lots of ActiveRecord objects when
    # all we need is a select box
    def quick_load_for_select(conditions = nil)
      sql = "SELECT #{get_quick_column} AS quick, id FROM #{connection.quote_table_name(table_name)}"
      sanitized_conditions = sanitize_sql_for_conditions(conditions)
      sql << " WHERE #{sanitized_conditions}" if sanitized_conditions
      sql << " ORDER BY quick ASC"
      result = connection.execute(sql)
      rows = []
      result.each{|row| rows << row}
      result.free

      rows
    end

    # set the column or other SQL expression which will be the title
    # in quickly-loaded sqlect boxes
    def quick_column(column)
      write_inheritable_attribute("quick_column", column)
    end

    def get_quick_column #:nodoc:
      read_inheritable_attribute("quick_column")
    end
  end

  def self.included(base)
    base.extend(ClassMethods)
  end
end
