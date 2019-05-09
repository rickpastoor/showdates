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

Given("user {string} is following show with tvdbid {string}") do |string, string2|
  SDUserShow.create(
    user: SDUser.find(emailaddress: string),
    show: SDShow.find(tvdbid: string2)
  )
end
