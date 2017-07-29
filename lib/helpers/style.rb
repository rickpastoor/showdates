module Sinatra
  module Flash
    module Style
      def styled_flash(key=:flash)
        return "" if flash(key).empty?
        id = (key == :flash ? "flash" : "flash_#{key}")
        messages = flash(key).collect {|message| "  <div class='notice notice-#{message[0]}'><div class='container'><p>#{message[1]}</p></div></div>\n"}
        "<div id='#{id}'>\n" + messages.join + "</div>"
      end
    end
  end
end
