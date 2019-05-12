# frozen_string_literal: true

require 'liquid'
require 'kramdown'
require 'roadie'
require 'nokogiri'
require 'uri'

# Converts markdown input and vars to html string
module EmailTemplate
  module_function

  def render(content:, layout: nil, vars: {}, utm_tags: nil)
    content = apply_vars(content, vars)

    content = Kramdown::Document.new(content).to_html

    content = apply_layout(content, layout, vars) if layout

    content = apply_utm(content, utm_tags) if utm_tags

    content
  end

  def apply_vars(string, vars)
    Liquid::Template.parse(string).render!(vars)
  end

  def apply_layout(content, layout, vars)
    vars['content'] = content

    parsed_template = Liquid::Template.parse(open_template("assets/emails/layout/#{layout}.html"))
    email_template = parsed_template.render!(vars)

    # Inline CSS
    roadie_document = Roadie::Document.new(email_template)
    roadie_document.transform
  end

  def apply_utm(content, params = {})
    return content if params == {}

    doc = Nokogiri::HTML.fragment(content)

    doc.css('a[href]').map do |element|
      uri = URI.parse(element['href'])
      current_params = URI.decode_www_form(uri.query || '')
                          .each_with_object({}) do |(key, value), r|
                            r[key.to_sym] = value
                          end
      uri.query = URI.encode_www_form(params.merge(current_params))

      element['href'] = uri.to_s
    end

    doc.to_xhtml.gsub('&amp;', '&')
  end

  def open_template(file)
    File.open(file, 'rb').read.force_encoding('UTF-8').encode(undef: :replace)
  end
end
