namespace :access_tokens do
  desc "Remove an access token for a user"
  task :remove_access_token, %i[owner_email] => :environment do |_, args|
    usage_message = "usage: rake access_tokens:remove_access_token[<owner_email>]".freeze
    abort usage_message if args[:owner_email].blank?

    token = AccessToken.find_by(owner: args[:owner_email])
    abort "Access token with owner #{args[:owner_email]} not found" unless token

    abort "Failed to remove token for #{args[:owner_email]}" unless token.destroy!
    puts "Access token removed for #{args[:owner_email]}"
  end
end
