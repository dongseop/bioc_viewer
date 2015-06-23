json.extract! @document, :id, :version, :user_id, :created_at, :updated_at
json.bioc do 
  json.source @document.bioc.source
  json.date @document.bioc.date
  json.key @document.bioc.key
  json.infon @document.bioc.infons
  json.documents @document.bioc.documents do |d|
    json.id d.id
    json.infon d.infons
    json.passages d.passages do |p|
      json.infon p.infons
      json.ofset p.offset
      json.text p.text unless p.text.nil?

      json.annotations p.annotations do |a|
        json.id a.id unless a.id.nil?
        json.infon a.infons
        json.location a.locations do |l|
          json.offset l.offset.to_i
          json.length l.length.to_i
        end
        json.text a.text 
      end unless p.annotations.empty?
      json.sentence p.sentences do |s|
        json.infon s.infons
        json.offset s.offset
        json.text s.text unless s.text.nil?
        json.annotation s.annotations do |a|
          json.id a.id unless a.id.nil?
          json.infon a.infons
          json.location a.locations do |l|
            json.offset l.offset.to_i
            json.length l.length.to_i
          end
          json.text a.text 
        end unless s.annotations.empty?
        json.relation s.relations do |r|
          json.id r.id unless r.id.nil?
          json.infon r.infons
          json.node r.nodes do |n|
            json.refid n.refid
            json.role n.role
          end
        end unless s.relations.empty?
      end unless p.sentences.empty?
      json.relation p.relations do |r|
        json.id r.id unless r.id.nil?
        json.infon r.infons
        json.node r.nodes do |n|
          json.refid n.refid
          json.role n.role
        end
      end unless p.relations.empty?
    end
    json.relation d.relations do |r|
      json.id r.id unless r.id.nil?
      json.infon r.infons
      json.node r.nodes do |n|
        json.refid n.refid
        json.role n.role
      end
    end unless d.relations.empty?
  end
end

