require 'csv'
class Ppi < ActiveRecord::Base
  belongs_to :document, counter_cache: true

  PPI_EXP = [
    "Affinity Capture-Luminescence",
    "Affinity Capture-MS",
    "Affinity Capture-RNA",
    "Affinity Capture-Western",
    "Biochemical Activity",
    "Co-crystal Structure",
    "Co-fractionation",
    "Co-localization",
    "Co-purification",
    "Far Western",
    "FRET",
    "PCA",
    "Protein-peptide",
    "Protein-RNA",
    "Reconstituted Complex",
    "Two-hybrid",
    "N/A"
  ]
  
  GI_EXP = [
    "Dosage Growth Defect",
    "Dosage Lethality",
    "Dosage Rescue",
    "Negative genetic",
    "Phenotypic Enhancement",
    "Phenotypic Suppression",
    "Positive genetic",
    "Synthetic Growth Defect",
    "Synthetic Haploinsufficiency",
    "Synthetic Lethality",
    "Synthetic Rescue",
    "N/A"
  ]

  def pmc
    if self.document.nil?
      ""
    else
      self.document.article_id_pmc
    end
  end

  def pmid
    if self.document.nil?
      ""
    else
      self.document.article_id_pmid
    end
  end

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << %w(Gene1 Name1 Gene2 Name2 Type Exp PMC PMID)
      all.each do |ppi|
        

        csv << [ppi.gene1, ppi.name1, ppi.gene2, ppi.name2, 
            ppi.itype.upcase, ppi.exp,
            ppi.pmc, ppi.pmid]
      end
    end
  end
end
