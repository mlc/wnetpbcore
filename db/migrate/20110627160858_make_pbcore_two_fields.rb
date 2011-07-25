class MakePbcoreTwoFields < ActiveRecord::Migration

  FIELDS = {
    :identifiers => ["ref", "annotation"],
    :titles => ["source", "ref", "annotation", "start_time", "end_time", "time_annotation"],
    :descriptions => ["description_type_source", "description_type_ref", "description_type_annotation", "segmentType", "segmentTypeSource", "segmentTypeRef", "segmentTypeAnnotation", "startTime", "endTime", "timeAnnotation", "annotation"],
    :relations => ["source", "ref", "annotation"],
    :coverages => ["source", "ref", "annotation", "startTime", "endTime", "timeAnnotation"]
  }

  def self.up
    FIELDS.each do |table, cols|
      cols.each do |col|
        add_column table, col.underscore.to_sym, :text, :default => nil, :null => true
      end
    end
  end

  def self.down
    FIELDS.each do |table, cols|
      cols.each do |col|
        remove_column table, col.underscore.to_sym
      end
    end
  end
end
