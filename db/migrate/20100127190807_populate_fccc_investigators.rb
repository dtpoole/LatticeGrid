class PopulateFcccInvestigators < ActiveRecord::Migration
  def self.up
    
    research = Hash.new
        
    # Research
    research["Immune Cell Development and Host Defense"] = %w(rall wiest talsaleem sbalacha kcampbel acohen hardy hayakawa kappes mason jrhodes vrobu seeger ljsigal skalka msmith taylor)
    research["Cancer Biology"] = %w(chernoff testa bellacos sboorjia pcairns edcukier genders hfan ghudes rkatz kleinsz agknudso vmkolenk kruger bluo bmintz aoreilly jpeterso froegier altulin ruzzo hyan yen)
    research["Developmental Therapeutics"] = %w(gadams rbcohen golemis iastsatu hborghaei zibu bburtnes mbuyyounouski lchen scohen modoss dunbrack eahopper jaffe slessin rmehra mmurphy aolszans jridge mkrobins roder gsimon mvonmehren yeung jyu cdenling cma eplimack nsomaiah jcheng )
    research["Women's Cancer"] = %w(mcristof godwin jefboyd rburger xwchen dcconnol jfdorgan lgoldstein thamilto lmartin mamorgan irusso russo rschilder mseiden esigurdson rswaby jlewis rzhang panderso rbleiche cdenling hdushkin kevers freedman sakim apatchef eariazi)
    research["Cancer Prevention and Control"] = %w(fang clapper ambarsev jrbeck abradbur daly pengstrom lfleishe vgiri mhall checkman alazev manne miller pshapiro dweinberg ywong wchang hcooper ross)

    # Keystones
    #research["Blood Cell Development"] = %w(wiest hardy kappes talsaleem kcampbel acohen hayakawa jrhodes vrobu ljsigal msmith testa)
    #research["Epigenetics and Progenitor Cells"] = %w(bellacos froegier pcairns chernoff rbcohen dunbrack genders hfan golemis hardy kappes rkatz aoreilly jrhodes msmith altulin wiest hyan yen rzhang)
    #research["Head & Neck"] = %w(bburtnes golemis jridge gadams iastsatu hborghaei clapper rbcohen dunbrack beglesto fang godwin eahopper jaffe kleinsz mlango rmehra mmurphy nicolaou jpeterso mkrobins roder serebrii jyu)
    #research["Kidney Cancer"] = %w(ruzzo ghudes testa gadams talsaleem sbalacha sboorjia pcairns dchen chernoff edcukier beglesto golemis rgreenberg agknudso kruger eplimack ross rviterbo ywong)
    #research["Risk Assessment"] = %w(daly clapper hborghaei abradbur wchang hcooper beglesto kevers dflieder vgiri godwin mhall checkman alazev ross russo munger dweinberg jyu mzook)
        
    research.each do |program_title, investigators|
      program = Program.find(:first, :conditions => {:name => program_title})
      puts "Program: #{program.id} - #{program_title}"
      investigators.each do |username|
        puts "\tAdding #{username}..."
        i = Investigator.find(:first, :conditions => {:username => username})
        
        if !i
           puts "\t\tNot Found."
           pi_data = GetLDAPentry(username)
           i = MakePIfromLDAP(pi_data)
           CreateOrUpdatePI(i)
           puts "\t\tCreated #{i.name}"
        end        
        InvestigatorAppointment.create(:organizational_unit_id => "#{program.id}", :investigator_id => "#{i.id}", :type => "Member")
      end
    end
    
    # don't have column name of type...
    ActiveRecord::Base::connection().update("UPDATE investigator_appointments set type='Member'") 
    
  end

  def self.down
    InvestigatorAppointment.destroy_all
  end
end
