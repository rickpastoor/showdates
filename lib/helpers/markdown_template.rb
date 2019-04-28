# frozen_string_literal: true

require 'liquid'
require 'kramdown'
require 'roadie'

# Converts a markdown file and variables to string
module MarkdownTemplate
  module_function

  def render(template, vars = {})
    file_parts = separate_config(open_template("assets/#{template}.md"))

    # Parse config
    config = parse_config(file_parts.config)

    # Add config to vars
    vars['base_url'] = ENV['BASE_URL']
    vars['config'] = config
    vars['preheader'] = apply_vars(config['preheader'], vars) if config['preheader']

    # Process Liquid body
    rendered_template = apply_vars(file_parts.content, vars)

    # Process Liquid subject
    config['subject'] = apply_vars(config['subject'], vars) if config['subject']

    email_template = Kramdown::Document.new(rendered_template).to_html

    email_template_layout = apply_layout(email_template, vars) if vars['config']['layout']

    {
      config: config,
      template: email_template_layout || email_template,
      template_body: email_template
    }
  end

  def apply_layout(email_template, vars)
    vars['content'] = email_template

    parsed_template = Liquid::Template.parse(open_template("assets/emails/layout/#{vars['config']['layout']}.html"))
    email_template = parsed_template.render!(vars)

    # Inline CSS
    roadie_document = Roadie::Document.new(email_template)
    roadie_document.transform
  end

  def apply_vars(string, vars)
    Liquid::Template.parse(string).render!(vars)
  end

  def open_template(file)
    File.open(file, 'rb').read.force_encoding('UTF-8').encode(undef: :replace)
  end

  def separate_config(input)
    matches = /(---\n(.*)\n---\n)(.*)/im.match(input)

    if matches
      return OpenStruct.new(
        config: matches[1].strip,
        content: matches[3].strip
      )
    end

    OpenStruct.new(
      content: input.strip
    )
  end

  def parse_config(input)
    return unless input

    items = input.split("\n")

    results = {}

    items.each do |item|
      if item.include? ':'
        parts = item.split(':')
        results[parts.shift] = parts.join(':').strip
      end
    end

    results
  end
end
