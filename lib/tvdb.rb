require 'httparty'
require 'zip'

module TVDB
  module_function

  def baseUrl
    'http://thetvdb.com/api/' + ENV['THETVDB_APIKEY']
  end

  def getUpdatesXML
    TBDB::getRemoteXML(
      :temp_name => 'showdates_shows',
      :url => baseUrl + "/updates/updates_week.zip",
      :entry => 'updates_week.xml'
    )
  end

  def getShowXML(tvdb_id)
    TVDB::getRemoteXML(
      :temp_name => 'showdates_show',
      :url => baseUrl + "/series/#{tvdb_id}/all/en.zip",
      :entry => 'en.xml'
    )
  end

  def getShowBannerXML(tvdb_id)
    HTTParty.get(baseUrl + "/series/#{tvdb_id}/banners.xml").body
  end

  def getRemoteXML(temp_name:, url:, entry:)
    zipfile = Tempfile.new(temp_name)
    zipfile.binmode
    zipfile.write(HTTParty.get(url).body)
    zipfile.close

    Zip::File.open(zipfile.path) do |file|
      return file.read(file.find_entry(entry))
    end
  end
end
