class PopulateFcccPrograms < ActiveRecord::Migration
  def self.up
    
    research = Array.new    
    research << "Immune Cell Development and Host Defense"
    research << "Cancer Biology"
    research << "Developmental Therapeutics"
    research << "Women's Cancer"
    research << "Cancer Prevention and Control"
    
    keystones = Array.new
    keystones << "Blood Cell Development"
    keystones << "Epigenetics and Progenitor Cells"
    keystones << "Head & Neck"
    keystones << "Kidney Cancer"
    keystones << "Risk Assessment"

    departments = Hash.new
    #departments["Keystone Programs for Collaborative Discovery"] = keystones
    
    department_id = 1
    
    head = Program.create(:name => "Fox Chase Cancer Center", 
      :search_name => "Fox Chase Cancer Center", 
      :abbreviation => "FCCC", 
      :type => "Center", 
      :department_id => department_id
    )    
    department_id += 1
    
    # Research
    
    research.each do |name|
      program = Program.create(:name => name,
        :search_name => name,
        :abbreviation => name,
        :type => 'Program',
        :department_id => department_id
      )
      program.move_to_child_of(head)
      department_id += 1
    end

    # Keystones
    
    departments.each do |department, programs|
      parent = Program.create(:name => department,
        :search_name => department,
        :abbreviation => department,
        :type => "Department",
        :department_id => department_id
      )
      parent.move_to_child_of(head)
      department_id += 1
      
      programs.each do |name|
        program = Program.create(:name => name,
          :search_name => name,
          :abbreviation => name,
          :type => 'Program',
          :department_id => department_id
        )
        program.move_to_child_of(parent)
        department_id += 1
      end
    end
  end

  def self.down
    Program.destroy_all
  end
end
