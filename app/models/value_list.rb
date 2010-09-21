class ValueList < ActiveRecord::Base
  has_many :values, :dependent => :delete_all

  PERMITTED_FIELDS = [
    "ContributorRole",
    "CreatorRole",
    "PublisherRole",
    "RelationType",
    "TitleType"
  ].freeze

  validates_presence_of :category
  validates_presence_of :value
  validates_uniqueness_of :value, :scope => :category
  validates_inclusion_of :category, :in => PERMITTED_FIELDS

  def name
    "#{category.titleize}: #{value}"
  end

  def self.permitted_fields_for_select
    [[]] + PERMITTED_FIELDS.map(&:titleize).zip(PERMITTED_FIELDS)
  end

  def self.permitted_values_json
    h = {}
    PERMITTED_FIELDS.each do |f|
      h[f] = f.constantize.quick_load_for_select(["visible = ?", true])
    end
    h.to_json
  end

  # creating ActiveRecord objects can be ...s...l...o...w...
  def self.quick_load_all_for_edit_form
    # VALUES is a keyword in SQL, so we have to be a bit careful with
    # the quoting; let's be a bit over-careful just in case someone
    # thinks VALUE is a keyword too.
    sql = "SELECT t1.category, t1.#{connection.quote_column_name("value")}, t2.#{connection.quote_column_name("value")} FROM #{connection.quote_table_name("value_lists")} t1, #{connection.quote_table_name("values")} t2 WHERE t1.id=t2.value_list_id ORDER BY t1.id, t2.#{connection.quote_column_name("value")}"
    result = connection.execute(sql)

    hash = {}
    result.each do |row|
      hash[row[0]] ||= {}
      hash[row[0]][row[1]] ||= []
      hash[row[0]][row[1]] << row[2]
    end
    result.free

    hash
  end

  def bulk_values
    values.all(:order => "value ASC").map(&:value).join("\n")
  end

  def bulk_values=(bulk)
    self.values = bulk.strip.split(/\r\n|\r|\n/).map{|v| Value.new(:value => v.strip)}
  end
end
