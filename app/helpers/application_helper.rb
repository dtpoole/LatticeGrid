# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include TagsHelper
  
  def menu_head_abbreviation
    "Feinberg"
  end
  def title_abbreviation
    "Feinberg"
  end
  
  def build_menu(nodes, org_type=nil, &block)
    out="<ul>"
		for unit in nodes
		  if org_type.nil? or unit.kind_of?(org_type)
    		out+="<li>"
    		out+=link_to( unit.abbreviation.gsub(/\'/, ""), yield(unit.id))
        out+=build_menu(unit.children, nil, &block) if ! unit.leaf?
    		out+="</li>"
  		end
		end
		out+="</ul>"
		out
	end
  
  def build_year_menu
    out="<ul>"
		for the_year in @year_array
			if  controller.action_name.match('year_list') != nil && the_year.to_s == @year
				out+="<li class='current'>"
			else
    		out+="<li>"
			end
			out+=link_to( the_year, abstracts_by_year_path(:id => the_year, :page=> 1))
   		out+="</li>"
		end
		out+="</ul>"
		out
	end
	
  def capitalize_words(string) 
    string.downcase.gsub(/\b\w/) { $&.upcase } 
  end 

  def abstracts_per_year(abstracts, year_array)
    years=Array.new(year_array.length, 0)
    first_year = year_array[0]
    abstracts.each do |abs|
      pos = abs.year.to_i - first_year.to_i
      years[pos]=years[pos]+1 if pos >= 0
    end
    years
  end   

  def isInvestigatorFirstAuthor(citation,investigator)
    if getFirstAuthorForCitation(citation) == investigator
      return true
    end
    return false
  end

  def isInvestigatorLastAuthor(citation,investigator)
    if getLastAuthorForCitation(citation) == investigator
      return true
    end
    return false
   end
  
  def setInvestigatorClass(citation,investigator)
    if isInvestigatorLastAuthor(citation,investigator) : "last_author" 
    elsif isInvestigatorFirstAuthor(citation,investigator) : "first_author"
    else
      "author"
    end
  end

	def link_to_coauthors(coauthors, delimiter=", ")
	  coauthors.collect{|coauthor| link_to( coauthor.colleague.name, 
		show_investigator_path(:id=>coauthor.colleague.username, :page=>1), # can't use this form for usernames including non-ascii characters
		  :title => " #{coauthor.colleague.total_pubs} pubs, "+(coauthor.colleague.num_intraunit_collaborators+coauthor.colleague.num_extraunit_collaborators).to_s+" collaborators")}.join(delimiter)
	end
	
  def link_to_collaborators(collaborators, delimiter=", ")
    collaborators.collect{|investigator| link_to( investigator.name, 
      show_investigator_path(:id=>investigator.username, :page=>1), # can't use this form for usernames including non-ascii characters
        :title => " #{investigator.total_pubs} pubs, "+(investigator.num_intraunit_collaborators+investigator.num_extraunit_collaborators).to_s+" collaborators")}.join(delimiter)
  end
  
  def link_to_similar_investigators(relationships, delimiter=", ")
    relationships.collect{|relationship| link_to( "#{relationship.colleague.name} <span class='simularity'>#{(relationship.mesh_tags_ic/10).round}</span>", 
      show_investigator_path(:id=>relationship.colleague.username, :page=>1), # can't use this form for usernames including non-ascii characters
        :title => " #{relationship.colleague.total_pubs} pubs, "+(relationship.colleague.num_intraunit_collaborators+relationship.colleague.num_extraunit_collaborators).to_s+" collaborators")}.join(delimiter)
  end
  
  def link_to_investigator(citation, investigator, name=nil) 
    name=investigator.last_name if name.blank?
    link_to name, 
      show_investigator_path(:id=>investigator.username, :page=>1), # can't use this form for usernames including non-ascii characters
      :class => setInvestigatorClass(citation,investigator),
      :title => "Go to #{name}: #{investigator.total_pubs} pubs, "+(investigator.num_intraunit_collaborators+investigator.num_extraunit_collaborators).to_s+" collaborators"
  end
  
  def getFirstAuthorIDForCitation(citation)
    citation.investigator_abstracts.each do |investigator_abstract|
      return investigator_abstract.investigator_id if investigator_abstract.is_first_author
    end
    return nil
  end

  def getFirstAuthorForCitation(citation)
    author_id = getFirstAuthorIDForCitation(citation)
    return nil if author_id.blank?
    citation.investigators.each do |investigator|
      return investigator if investigator.id == author_id
    end
    return nil
  end

  def getLastAuthorIDForCitation(citation)
    citation.investigator_abstracts.each do |investigator_abstract|
      return investigator_abstract.investigator_id if investigator_abstract.is_last_author
    end
    return nil
  end

  def getLastAuthorForCitation(citation)
    author_id = getLastAuthorIDForCitation(citation)
    return nil if author_id.blank?
    citation.investigators.each do |investigator|
      return investigator if investigator.id == author_id
    end
    return nil
  end

  def author_name(author)
    author.last_name+',  '+author.first_name.at(0)+(author.middle_name.blank? ? '' : author.middle_name.at(0) )
  end
    
  def highlightInvestigator(citation, authorList=nil)
    if authorList.blank?
      authors = citation.authors.gsub("\n","; ")
    else
      authors = authorList.gsub("\n","; ")
    end
    citation.investigators.each do |investigator|
      re = Regexp.new('('+investigator.last_name+', '+investigator.first_name.at(0)+'[^;]+)') 
      authors.gsub!(re){|match| link_to_investigator(citation, investigator, author_name(investigator))}
    end
    authors
  end
  
  def markProgramMembership(citation, programID)
    if citation.investigators.length > 1 then
      getMembershipMarker(citation,programID)
    end
  end

  def getMembershipMarker(citation,programID)
    intra=0
    inter=0
    marker=""
    citation.investigators.each do |investigator|
      if investigator.investigator_programs.has_program(programID) then
        intra+=1
      else
        inter+=1
      end
    end
    marker="*" if intra > 1
    marker=marker+" §" if inter > 0
    return marker
  end
  
  def link_to_primary_department(investigator)
    return link_to( investigator.home_department.name, show_investigators_org_path(investigator.home_department_id), :title => "Show investigators in #{investigator.home_department.name}" ) if !investigator.home_department_id.nil?
    begin
      return investigator.home if ! investigator.home.nil?
    rescue
      ""
    end
    return ""
  end
  
  def link_to_units(appointments, delimiter="<br/>")
      appointments.collect{ |appointment| 
          link_to( appointment.name, show_investigators_org_path(appointment.id), 
          :title => "Show investigators in #{appointment.name}")}.join(delimiter)
  end
end
