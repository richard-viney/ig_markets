require 'mechanize'

agent = Mechanize.new
page = agent.get 'http://labs.ig.com/rest-trading-api-reference'

page.links_with(href: %r{/rest-trading-api-reference/}).each do |link|
  puts link.href

  api_page = agent.get link.href

  api_page.search('td.errorcode').each do |error|
    error = error.children.map(&:text).join

    next if File.read('lib/ig_markets/errors.rb').include? "'#{error}'"

    puts "    #{error}"
  end
end
