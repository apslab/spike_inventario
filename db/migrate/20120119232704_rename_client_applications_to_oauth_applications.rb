class RenameClientApplicationsToOauthApplications < ActiveRecord::Migration
  def up
    rename_table(:client_applications, :oauth_applications)
  end

  def down
    rename_table(:oauth_applications, :client_applications)
  end
end
