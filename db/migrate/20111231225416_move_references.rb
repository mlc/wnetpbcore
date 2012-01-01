class MoveReferences < ActiveRecord::Migration
  def self.up
    # Subjects
    subjects = Subject.all(:conditions => ["subject_authority like ?", "http%"])
    subjects.each do |subject|
      subject.ref = subject.subject_authority
      subject.subject_authority = "Library of Congress Name Authority"
      subject.save
    end
    
    regex = /^(.*) \((http.*)\)$/
    
    # Coverages
    coverages = Coverage.all(:conditions => ["coverage like ?", "%http%"])
    coverages.each do |coverage|
      if coverage.coverage =~ regex
        coverage.coverage = $1
        coverage.ref = $2
        if coverage.ref =~ /loc\.gov/
          coverage.source = "Library of Congress Name Authority"
        end
        coverage.save
      end
    end
    
    # Contributors
    contributors = Contributor.all(:conditions => ["contributor like ?", "%http%"])
    contributors.each do |contributor|
      if contributor.contributor =~ regex
        contributor.contributor = $1
        contributor.ref = $2
        if contributor.ref =~ /loc\.gov/
          contributor.source = "Library of Congress Name Authority"
        end
        contributor.save
      end
    end
    
    # Creators
    creators = Creator.all(:conditions => ["creator like ?", "%http%"])
    creators.each do |creator|
      if creator.creator =~ regex
        creator.creator = $1
        creator.ref = $2
        if creator.ref =~ /loc\.gov/
          creator.source = "Library of Congress Name Authority"
        end
        creator.save
      end
    end
    
    # Publishers
    publishers = Publisher.all(:conditions => ["publisher like ?", "%http%"])
    publishers.each do |publisher|
      if publisher.publisher =~ regex
        publisher.publisher = $1
        publisher.ref = $2
        if publisher.ref =~ /loc\.gov/
          publisher.ref = "Library of Congress Name Authority"
        end
        publisher.save
      end
    end
  end

  def self.down
  end
end
