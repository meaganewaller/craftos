Sequel.migration do
  change do
    create_table(:users) do
      primary_key :id
      String :username, null: false, unique: true
      String :password_digest, null: false
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
    end
  end
end
