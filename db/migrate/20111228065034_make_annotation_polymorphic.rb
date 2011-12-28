class MakeAnnotationPolymorphic < ActiveRecord::Migration
  def self.up
    rename_column :annotations, :instantiation_id, :container_id
    add_column :annotations, :container_type, :string
    
    Annotation.find_in_batches do |annotation_batch|
      annotation_batch.each do |annotation|
        annotation.container_type = "Instantiation"
        # If there is an annotation
        if annotation.annotation.present?
          # Try and split the annotation at the first colon
          annotation_elements = annotation.annotation.split(":", 2)
          # If the split was successful, move the first part of the 
          # split into annotation_type and put the second part back
          # in annotation.
          if annotation_elements.size == 2
            annotation.annotation_type = annotation_elements[0]
            annotation.annotation = annotation_elements[1].lstrip
          end
        end
        annotation.save
      end
    end
  end
  
  def self.down
    remove_column :annotations, :container_type
    rename_column :annotations, :container_id, :instantiation_id
  end
end