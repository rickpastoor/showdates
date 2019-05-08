# frozen_string_literal: true

Given /^these users:$/ do |table|
  table.hashes.each do |row|
    user = SDUser.new(
      firstname: row[:firstname],
      lastname: row[:lastname],
      emailaddress: row[:emailaddress],
      timezone: row[:timezone] || 'UTC',
      is_admin: row[:is_admin] == 'true' || false,
      sendemailnotice: row[:sendemailnotice] || 'unknown',
    )

    user.save
  end
end
