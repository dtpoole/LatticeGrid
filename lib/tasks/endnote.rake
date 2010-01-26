# (c) Copyright 2010 David Poole. All Rights Reserved.

require 'endnote_xml'

namespace :endnote do
  @verbose = true
  
  desc "import abstracts from an Endnote XML file"
  task :import => :environment do
    raise "usage: rake endnote:import file={filename}" unless ENV.include?("file")
    block_timing("endnote:import") do
      import = EndNoteXML::Import.new(ENV['file'].strip, @verbose)
    end
  end
end