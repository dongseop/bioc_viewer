require 'csv'
class Ppi < ActiveRecord::Base
  belongs_to :document, counter_cache: true

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      all.each do |ppi|
        csv << [ppi.gene1, ppi.gene2]
      end
    end
  end
end
