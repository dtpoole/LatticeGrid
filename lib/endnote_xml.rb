# (c) Copyright 2010 David Poole. All Rights Reserved. 

module EndNoteXML
  
  require 'date'
  require 'sax-machine'
  
  ISIWEB = 'http://gateway.isiknowledge.com/gateway/Gateway.cgi?GWVersion=2&SrcAuth=Alerting&SrcApp=Alerting&DestApp=CCC&DestLinkType=FullRecord&KeyUT=ISI:'
  
  class Dates
    include SAXMachine
    elements :date, :as => :dates
  
    def to_s
      dates.first
    end
  end

  class Authors
    include SAXMachine
    elements :author, :as => :authors
    def to_s
      authors.join("\n")
    end
    def to_str
      to_s
    end
  end

  class Contributors
    include SAXMachine
    elements 'secondary-authors', :as => :editors, :class => Authors
    elements :authors, :as => :authors, :class => Authors
  end

  class Periodical
    include SAXMachine
    element 'full-title', :as => :journal
    element 'abbr-1', :as => :journal_abbr
  end
  
  class Keywords
    include SAXMachine
    elements :keyword, :as => :keywords
    
    def to_s
      # remove .'s from keywords.  They cause problems with tag clouds
      a = keywords.collect! {|x| x.gsub('.', '').dup }
      a.join(";\n")
    end
    
    def to_str
      to_s
    end
  end

  class Publication
    include SAXMachine
    element 'accession-num', :as => :accession
    element 'rec-number', :as => :endnote_id
    element :abstract
    element 'accession-num', :as => :accession
    element 'pub-location', :as => :publisher_location
    elements :periodical, :as => :periodical, :class => Periodical
    elements :contributors, :as => :contributors, :class => Contributors
    element :publisher
    element :pages
    element :volume
    element :title
    element "secondary-title", :as => :secondary_title
    element :number, :as => :issue
    elements 'pub-dates', :as => :pub_dates, :class => Dates
    element :year
    element 'ref-type', :value => :name,  :as => :kind
    elements :keywords, :as => :keywords, :class => Keywords
    elements :url, :as => :urls
    element :custom2, :as => :pmcid
  
    def journal
      # if journal is empty use the secondary_title field for journal.
      # if we have a journal and secondary_title is greater or equal in length use secondary_title.
      # journal may be 'Jama' and secondary_title may be 'JAMA'.  We prefer all caps.
      journal_name = periodical.size > 0 ? periodical.first.journal : nil
      if journal_name.nil? and secondary_title
        journal_name = secondary_title          
      elsif journal_name and secondary_title
        if journal_name != secondary_title and secondary_title.length >= journal_name.length
            journal_name = secondary_title
        end
      end
      journal_name
    end
    
    def journal_abbreviation
      periodical.size > 0 ? periodical.first.journal_abbr : nil
    end
    
    def authors
      contributors.first.authors.to_s
    end

    def editors
      contributors.first.editors.to_s
    end
    
    def date
      d = pub_dates.first.to_s.strip.gsub('.', '')
      begin
         "#{year}-#{Date.parse(d).strftime('%m-%d')}"
      rescue ArgumentError
         "#{year}-01-01"
      end
    end
    
    def url
      # make sure it's a proper url.  Fix ISI's like '<Go to ISI>://000085288800047'
      if url = urls.first
        url.strip!
        if url =~ /^<Go to ISI>/
          EndNoteXML::ISIWEB + url.split('//').last
        elsif url !~ /^http/
          nil
        else
          url
        end
      end
    end
      
    def to_s
      "#{endnote_id} - #{kind} - #{title}"
    end
    
    def to_str
      to_s
    end
  end

  class Publications
    include SAXMachine
    elements :record, :as => :publications, :class => Publication
  end
  
  
  class Import
    
    def initialize(filename, verbose = false)
      @filename = filename
      @work_filename = "#{@filename}-" + Time.now.to_i.to_s
      @count = @added = @updated = @errors = 0
      @errors = Hash.new
      @verbose = verbose
      import
    end
    
    private
    
    def import
    
      raise "File does not exist. (#{@filename})" unless File.stat(@filename).file?
      
      report("Removing style tags...")
      if !strip_style_tags(@filename, @work_filename)
        raise "Error stripping <style> tags.  sed did not complete successfully."
      end
      
      LoadDate.create(:load_date=> Time.now)
      
      report("Parsing #{@work_filename}...")    
      EndNoteXML::Publications.parse(File.open(@work_filename)).publications.each do |pub|
        
        if abstract = Abstract.find(:first, :conditions => { :source_id => pub.endnote_id, :source => 'endnote' })
        
          report("UPDATING: #{pub}")

          begin
            abstract.update_attributes(
              :authors => pub.authors,
              :abstract => pub.abstract,
              :publication_date => pub.date,
              :title   => pub.title,
              :publication_type => pub.kind,
              :journal => pub.journal,
              :journal_abbreviation => pub.journal_abbreviation,
              :volume  => pub.volume,
              :issue   => pub.issue,
              :pages   => pub.pages,
              :year    => pub.year,
              :mesh    => pub.keywords != '' ? pub.keywords.to_s : nil,
              :url     => pub.url,
              :editors => pub.editors,
              :publisher_location => pub.publisher_location,
              :publisher => pub.publisher,
              :pmcid => pub.pmcid
            )
            @updated += 1
          rescue ActiveRecord::RecordInvalid => invalid
             @errors[pub.endnote_id] = invalid.record.errors.full_messages.join("\n")
          end
        
        else
          
          report("ADDING: #{pub}")
          
          abstract = Abstract.new(
            :source => 'endnote',
            :source_id => pub.endnote_id,
            :authors => pub.authors,
            :abstract => pub.abstract,
            :publication_date => pub.date,
            :title   => pub.title,
            :publication_type => pub.kind,
            :journal => pub.journal,
            :journal_abbreviation => pub.journal_abbreviation,
            :volume  => pub.volume,
            :issue   => pub.issue,
            :pages   => pub.pages,
            :year    => pub.year,
            :mesh    => pub.keywords != '' ? pub.keywords.to_s : nil,
            :url     => pub.url,
            :editors => pub.editors,
            :publisher_location => pub.publisher_location,
            :publisher => pub.publisher,
            :pmcid => pub.pmcid
          )

          begin
             abstract.save!
             @added += 1
          rescue ActiveRecord::RecordInvalid => invalid
            @errors[pub.endnote_id] = invalid.record.errors.full_messages.join("\n")
          end
          
        end
        
        report()
        
        @count += 1
      end
      
      FileUtils.remove_file(@work_filename)
      
      report("File successfully imported.")
      
      report("The following errors occured:") if !@errors.empty?
      @errors.each do |id, msg|
        report("#{id} - #{msg}")
      end
      
      report("Parsed #{@count} publications.  Added #{@added}.  Updated #{@updated}.  Errors #{@errors.size}.")
    end

    def strip_style_tags(filename, work_filename)
      system "sed -e 's/<style[^>]*>//g' #{filename} | sed -e 's/<\\/style[^>]*>//g' > #{work_filename}"
    end
    
    def report(text = '')
      puts text if @verbose
    end
  
  end

end
