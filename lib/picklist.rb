# A lot of PBCore fields are extensible picklists.
module Picklist

  module ClassMethods
    # avoid instantiating lots and lots of ActiveRecord objects when
    # all we need is a select box
    def quick_load_for_select(conditions = nil)
      columns = (["#{get_quick_column} AS quick"] + (extra_quick_columns.to_a || []) + ["id"]).join(", ")
      sql = "SELECT #{columns} FROM #{connection.quote_table_name(table_name)}"
      sanitized_conditions = sanitize_sql_for_conditions(conditions)
      sql << " WHERE #{sanitized_conditions}" if sanitized_conditions
      sql << " ORDER BY quick ASC"

      result = connection.execute(sql)
      rows = []
      result.each{|row| row[-1] = row[-1].to_i; rows << row}
      result.free

      rows
    end

    # set the column or other SQL expression which will be the title
    # in quickly-loaded sqlect boxes
    def quick_column(column)
      write_inheritable_attribute("quick_column", column)
    end

    def get_quick_column # :nodoc:
      read_inheritable_attribute("quick_column")
    end

    # specify one or more extra columns to be returned by quick_load
    def extra_quick_column(*columns)
      write_inheritable_attribute("extra_quick_column", Set.new(columns.map(&:to_s)) + (extra_quick_columns || []))
    end

    def extra_quick_columns # :nodoc:
      read_inheritable_attribute("extra_quick_column")
    end
  end

  def self.included(base)
    base.extend(ClassMethods)
  end
end
