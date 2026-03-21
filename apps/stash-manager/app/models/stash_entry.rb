class StashEntry < Sequel::Model
  plugin :timestamps, update_on_create: true

  def validate
    super
    errors.add(:brand, "is required") if brand.nil? || brand.empty?
    errors.add(:line, "is required") if line.nil? || line.empty?
    errors.add(:yardage, "must be positive") unless yardage && yardage > 0
    errors.add(:skein_weight, "must be positive") unless skein_weight && skein_weight > 0
    errors.add(:quantity, "must be positive") unless quantity && quantity > 0
  end

  def total_yardage
    yardage * quantity
  end

  def to_hash
    {
      id: id,
      brand: brand,
      line: line,
      colorway: colorway,
      yardage: yardage,
      skein_weight: skein_weight,
      quantity: quantity,
      total_yardage: total_yardage
    }
  end
end
