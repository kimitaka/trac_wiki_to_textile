#!/usr/bin/env ruby

TRAC_DB_PATH = 'trac.db'
OUT_PATH = 'wiki'

require 'sqlite3'

def make_directory path
  return if File.exists? path
  parent = File.dirname path
  make_directory parent
  Dir.mkdir path
end

db = SQLite3::Database.new(TRAC_DB_PATH)
pages = db.execute('select name, text from wiki w2 where version = (select max(version) from wiki where name = w2.name);')

pages.each do |title, body|
  file_path = OUT_PATH + title.gsub(/\s/, '') + '.textile'
  make_directory (File.dirname file_path)
  File.open(file_path, 'w') do |file|
    body.gsub!(/\r/, '')
    body.gsub!(/\{\{\{([^\n]+?)\}\}\}/, '@\1@')
    body.gsub!(/\{\{\{\n#!([^\n]+?)(.+?)\}\}\}/m, '<pre><code class="\1">\2</code></pre>')
    body.gsub!(/\{\{\{(.+?)\}\}\}/m, '<pre>\1</pre>')
# macro
    body.gsub!(/\[\[BR\]\]/, '')
    body.gsub!(/\[\[PageOutline.*\]\]/, '{{toc}}')
    body.gsub!(/\[\[Image\((.+?)\)\]\]/, '!\1!')
# header
    body.gsub!(/=====\s(.+?)\s=====/, "h5. #{'\1'} \n\n")
    body.gsub!(/====\s(.+?)\s====/,   "h4. #{'\1'} \n\n")
    body.gsub!(/===\s(.+?)\s===/,     "h3. #{'\1'} \n\n")
    body.gsub!(/==\s(.+?)\s==/,       "h2. #{'\1'} \n\n")
    body.gsub!(/=\s(.+?)\s=[\s\n]*/,  "h1. #{'\1'} \n\n")
# table
    body.gsub!(/\|\|/,  "|")
# link
    body.gsub!(/\[(http[^\s\[\]]+)\s([^\[\]]+)\]/, ' "\2":\1' )
    body.gsub!(/\[([^\s]+)\s(.+)\]/, ' [[\1 | \2]] ')
    body.gsub!(/([^"\/\!])(([A-Z][a-z0-9]+){2,})/, ' \1[[\2]] ')
    body.gsub!(/\!(([A-Z][a-z0-9]+){2,})/, '\1')
# text decoration
    body.gsub!(/'''(.+)'''/, '*\1*')
    body.gsub!(/''(.+)''/, '_\1_')
    body.gsub!(/`(.+)`/, '@\1@')
# itemize
    body.gsub!(/^\s\s\s\*/, '***')
    body.gsub!(/^\s\s\*/, '**')
    body.gsub!(/^\s\*/, '*')
    body.gsub!(/^\s\s\s\d\./, '###')
    body.gsub!(/^\s\s\d\./, '##')
    body.gsub!(/^\s\d\./, '#')
    file.write(body)
  end
end
