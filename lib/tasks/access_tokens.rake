namespace :access_tokens do
  desc "Add a pre-generated token, using the SHA256 hex digest"
  task :insert, %i[owner token_digest] => :environment do |_, args|
    usage_message = "usage: rails access_tokens:insert[<owner>, <token_digest>]".freeze
    abort usage_message unless args[:owner].present? && args[:token_digest]&.match?(/^[a-f0-9]+$/)

    access_token = AccessToken.create!(
      description: "inserted with `rails access_tokens:insert`",
      owner: args[:owner],
      token_digest: args[:token_digest],
    )
    pp(access_token)
  end
end
