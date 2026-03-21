class StashService
  def list(search: nil)
    dataset = StashEntry.order(:brand, :line)
    if search && !search.empty?
      pattern = "%#{search}%"
      dataset = dataset.where(
        Sequel.ilike(:brand, pattern) |
        Sequel.ilike(:line, pattern) |
        Sequel.ilike(:colorway, pattern)
      )
    end
    dataset.all.map(&:to_hash)
  end

  def add(attrs)
    entry = StashEntry.new(
      brand: attrs[:brand],
      line: attrs[:line],
      colorway: attrs[:colorway],
      yardage: attrs[:yardage].to_f,
      skein_weight: attrs[:skein_weight].to_f,
      quantity: (attrs[:quantity] || 1).to_i
    )

    if entry.valid?
      entry.save
      {entry: entry.to_hash}
    else
      {errors: entry.errors.full_messages}
    end
  end

  def remove(id)
    entry = StashEntry[id]
    return false unless entry

    entry.destroy
    true
  end

  def check_yardage(required_yardage, yarn_id: nil)
    dataset = yarn_id ? StashEntry.where(id: yarn_id) : StashEntry
    available = dataset.all.sum(&:total_yardage)

    {
      required: required_yardage,
      available: available,
      sufficient: available >= required_yardage,
      shortage: [required_yardage - available, 0].max
    }
  end
end
