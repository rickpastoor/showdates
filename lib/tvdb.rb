require 'httparty'
require 'zip'

module TVDB
  module_function

  def baseUrl
    'http://thetvdb.com/api/' + ENV['THETVDB_APIKEY']
  end

  def getUpdatesXML
    zipfile = Tempfile.new('showdates_shows')
    zipfile.binmode
    zipfile.write(HTTParty.get(baseUrl + '/updates/updates_week.zip').body)
    zipfile.close

    Zip::File.open(zipfile.path) do |file|
      return file.read(file.find_entry('updates_week.xml'))
    end
  end

  def getShowXML(tvdb_id)
    zipfile = Tempfile.new('showdates_show')
    zipfile.binmode
    zipfile.write(HTTParty.get(baseUrl + "/series/#{tvdb_id}/all/en.zip").body)
    zipfile.close

    Zip::File.open(zipfile.path) do |file|
      return file.read(file.find_entry('en.xml'))
    end
  end
end
