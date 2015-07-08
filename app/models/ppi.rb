require 'csv'
class Ppi < ActiveRecord::Base
  belongs_to :document, counter_cache: true

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << %w(gene1 name1 gene2 name2 type)
      all.each do |ppi|
        csv << [ppi.gene1, ppi.name1, ppi.gene2, ppi.name2, ppi.itype]
      end
    end
  end
end
