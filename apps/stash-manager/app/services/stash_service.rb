class StashService
  def initialize(user)
    @user = user
  end

  def list(search: nil)
    dataset = @user.stash_entries_dataset.order(:brand, :line)
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
    entry = @user.add_stash_entry(
      brand: attrs[:brand],
      line: attrs[:line],
      colorway: attrs[:colorway],
      yardage: attrs[:yardage].to_f,
      skein_weight: attrs[:skein_weight].to_f,
      quantity: (attrs[:quantity] || 1).to_i
    )

    if entry.valid?
      {entry: entry.to_hash}
    else
      entry.destroy
      {errors: entry.errors.full_messages}
    end
  rescue Sequel::ValidationFailed => e
    {errors: e.model.errors.full_messages}
  end

  def remove(id)
    entry = @user.stash_entries_dataset.where(id: id).first
    return false unless entry

    entry.destroy
    true
  end

  def check_yardage(required_yardage, yarn_id: nil)
    dataset = yarn_id ? @user.stash_entries_dataset.where(id: yarn_id) : @user.stash_entries_dataset
    available = dataset.all.sum(&:total_yardage)

    {
      required: required_yardage,
      available: available,
      sufficient: available >= required_yardage,
      shortage: [required_yardage - available, 0].max
    }
  end
end
