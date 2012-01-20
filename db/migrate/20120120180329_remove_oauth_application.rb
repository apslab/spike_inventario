class RemoveOauthApplication < ActiveRecord::Migration
  def up
    drop_table :oauth_applications
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
