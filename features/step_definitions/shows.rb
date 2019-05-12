Given("these shows:") do |table|
  table.hashes.each do |row|
    SDShow.create(
      title: row[:title],
      tvdbid: row[:tvdbid]
    )
  end
end

Given("these seasons:") do |table|
  table.hashes.each do |row|
    SDSeason.unrestrict_primary_key

    SDSeason.create(
      id: row[:id],
      show: SDShow.find(tvdbid: row[:show]),
      title: row[:title]
    )

    SDSeason.restrict_primary_key
  end
end

Given("these episodes:") do |table|
  table.hashes.each do |row|
    SDEpisode.create(
      show: SDShow.find(tvdbid: row[:show]),
      season: SDSeason[row[:season]],
      title: row[:title],
      firstaired: row[:firstaired],
      order: row[:order]
    )
  end
end
