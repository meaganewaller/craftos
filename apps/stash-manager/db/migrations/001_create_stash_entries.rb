Sequel.migration do
  change do
    create_table(:stash_entries) do
      primary_key :id
      String :brand, null: false
      String :line, null: false
      String :colorway
      Float :yardage, null: false
      Float :skein_weight, null: false
      Integer :quantity, null: false, default: 1
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
    end
  end
end
