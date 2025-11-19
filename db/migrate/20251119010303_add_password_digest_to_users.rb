class AddPasswordDigestToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :password_digest, :string
    add_index :users, :email, unique: true unless index_exists?(:users, :email)
  end
end
