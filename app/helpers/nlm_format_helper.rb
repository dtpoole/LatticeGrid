# (c) Copyright 2010 David Poole. All Rights Reserved. 


module NlmFormatHelper
  
  def nlm_formatted_authors(authors, pub, highlight = true)
     display = Array.new

     authors.split("\n").each do |author|
        formatted = ""

        author.strip!
        next if author == ''

        author.gsub!('&apos;', "'")

        author.chop! if author =~ /,$/

        name = author.split(',')

        formatted = name[0] + " "

        # max 2 inititals
        given_name = name[1].to_s.split[0..1]

        if given_name.length == 1 and given_name[0] =~ /\./
           formatted += given_name[0].gsub(/\./, "")
        else
           given_name.each do |part|
              formatted += part.to_s[0,1]
           end
        end

        display << formatted.gsub(/\./, "").strip
     end

     nlm_authors = display.join(", ")

     if highlight
       pub.investigators.each do |investigator|
         re = Regexp.new('('+investigator.last_name+' '+investigator.first_name.at(0)+'[^,]*)')
         nlm_authors.gsub!(re){|match| link_to_investigator(pub, investigator, match)}
       end
     end

     nlm_authors

  end


  def nlm_page_format(pages)

     pages.gsub!(/\./, "")

     display = pages

     if pages =~ /^[0-9]+\-[0-9]+$/

        parts = pages.split('-')

        return parts[0] if parts[0] == parts[1]

        if parts[0].length == parts[1].length
           display = parts[0] + "-"

           a = parts[0].split(//)
           b = parts[1].split(//)

           for i in (0..b.length)
              if a[i] != b[i]
                 display += b[i..b.length].to_s
                 break
              end
           end
        end
     end
     display
  end


  def nlm_format_journal(pub, html=true, highlight_authors=true, omit_title=false)
     display = ""

     if !omit_title

       display = nlm_formatted_authors(pub.authors, pub, highlight_authors) + ". "

       if html
          display += link_to(pub.title, abstract_path(pub))
       else
          display += pub.title
       end

       display += "." if pub.title !~ /\.$/
       display += " "
     end

     journal = pub.journal_abbreviation ? pub.journal_abbreviation : pub.journal

     if journal
        display += journal.gsub(/\./, "") + ". "
     end

     if pub.year

       display += pub.year

       if pub.publication_date
         if pub.publication_date.day == 1
          date = pub.publication_date.strftime('%b')
         else
          date = pub.publication_date.strftime('%b %d')
         end
         display += " " + date if date != 'Jan 01'
       end

      display += ";"       

     end

     display += pub.volume if pub.volume
     display += "(#{pub.issue})" if pub.issue

     display += ":" + nlm_page_format(pub.pages) if pub.pages and pub.pages.length > 0

     display += "."
  end
  
  
  def nlm_format_book(pub, html=true, highlight_authors=true, omit_title=false)
    display = "BOOK"
    
    if !omit_title
      display = nlm_formatted_authors(pub.authors, pub, highlight_authors) + ". "

      if html
         display += link_to(pub.title, abstract_path(pub))
      else
         display += pub.title
      end

      display += "." if pub.title !~ /\.$/
      display += " "
    end
    
    if pub.editors != ''
      display += nlm_formatted_authors(pub.editors, pub, false) + ", "
      display += pub.editors =~ /\n/ ? 'editors. ' : 'editor. '
    end

    display += pub.publisher_location + ": " if pub.publisher_location
    display += pub.publisher + "; " if pub.publisher
    display += pub.year + ". " if pub.year
    display
  end
  
  
  def nlm_format_book_section(pub, html=true, highlight_authors=true, omit_title=false)
    display = ""
    
    if !omit_title
      display = nlm_formatted_authors(pub.authors, pub, highlight_authors) + ". "

      if html
         display += link_to(pub.title, abstract_path(pub))
      else
         display += pub.title
      end

      display += "." if pub.title !~ /\.$/
      display += " "
    end

    display += "In: "

    if pub.editors != ''
      display += nlm_formatted_authors(pub.editors, pub, false) + ", "
      display += pub.editors =~ /\n/ ? 'editors. ' : 'editor. '
    end

    journal = pub.journal_abbreviation ? pub.journal_abbreviation : pub.journal

    if journal
       display += journal.gsub(/\./, "") + ". "
    end

    display += pub.publisher_location + ": " if pub.publisher_location
    display += pub.publisher + "; " if pub.publisher

    display += pub.year + ". " if pub.year

    display += "p. " + nlm_page_format(pub.pages) + ". " if pub.pages and pub.pages.length > 0

    display
  end
  
  def nlm_format_publication(publication, html=true, highlight_authors=true, omit_title=false)
    if publication.publication_type == 'Book'
      nlm_format_book(publication, html, highlight_authors, omit_title)
    elsif publication.publication_type == 'Book Section'
      nlm_format_book_section(publication, html, highlight_authors, omit_title)
    else
      nlm_format_journal(publication, html, highlight_authors, omit_title)
    end
  end
  
end