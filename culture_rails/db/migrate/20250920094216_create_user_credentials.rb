class CreateUserCredentials < ActiveRecord::Migration[8.0]
  def change
    create_table :user_credentials do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.string :email_address, null: false
      t.string :password_digest, null: false

      t.timestamps
    end

    add_index :user_credentials, :email_address, unique: true
  end
end
