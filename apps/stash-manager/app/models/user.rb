require "bcrypt"

class User < Sequel::Model
  plugin :timestamps, update_on_create: true
  one_to_many :stash_entries

  def password=(plain)
    self.password_digest = BCrypt::Password.create(plain)
  end

  def authenticate(plain)
    BCrypt::Password.new(password_digest) == plain
  end

  def validate
    super
    errors.add(:username, "is required") if username.nil? || username.empty?
    errors.add(:password_digest, "is required") if password_digest.nil? || password_digest.empty?
  end
end
