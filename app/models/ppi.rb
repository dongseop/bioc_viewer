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
    "Synthetic Rescue"
  ]

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << %w(gene1 name1 gene2 name2 type)
      all.each do |ppi|
        csv << [ppi.gene1, ppi.name1, ppi.gene2, ppi.name2, ppi.itype]
      end
    end
  end
end
