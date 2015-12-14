class Atype < ActiveRecord::Base
  belongs_to :docuemnt
  CLASSES = %w(C0 C1 C2 C3 C4 C5 C6 C7 C8 C9 C10 C11)
  BORDERS = %w(C6 C7 C8 C9 C10 C11)
  CLS_COLORS = [
    '#F2711C',
    '#FBBD08',
    '#B5CC18',
    '#21BA45',
    '#3195E0',
    '#E03997',
    '#DB2828',
    '#FBBD08',
    '#B5CC18',
    '#21BA45',
    '#2185D0',
    '#6435C9',
  ];

  TYPE2COLOR = {
    "gene" => "C1",
    "organism" => "C2",
    "experimentalmethod" => "C6",
    "geneticinteractiontype" => "C10",
    "gievidence" => "C9",
    "gimention" => "C8",
    "ppievidence" => "C7",
    "ppimention" => "C6"
  }

  def self.border?(cls)
    Atype::BORDERS.include?(cls)
  end

  def border?
    Atype.border?(self.cls)
  end

  def self.color(cls)
    idx = cls[1..-1].to_i
    Atype::CLS_COLORS[idx]
  end

  def color
    Atype.color(self.cls)
  end

  def cname
    return "A#{self.id}"
  end

  def self.recommend(name)
    ret = Atype.where('name=?', name).first
    if ret.nil?
      if Atype::TYPE2COLOR[name].nil?
        c = Random.rand(Atype::CLASSES.size)
        return Atype::CLASSES[c]
      else
        return Atype::TYPE2COLOR[name]
      end
    end

    ret.cls
  end
end
