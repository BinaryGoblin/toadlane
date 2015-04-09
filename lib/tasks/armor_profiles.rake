
namespace :armor do
  desc 'migrate deprecated ArmorProfile information to User'
  task migrate_profiles: :environment do
    ArmorProfile.all.each do |profile|
      if profile.armor_account_id && profile.armor_user_id
        begin
          profile.user.update_columns(
            armor_account_id: profile.armor_account_id,
            armor_user_id: profile.armor_user_id
          )
          Rails.info "Profile information migrated for ArmorProfile: #{profile.id}"
        rescue => e
          Rails.debug e.inspect
        end
      end
    end
  end
end

