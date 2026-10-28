class DiscoveryController < ApplicationController
  def sitemap
    xml = Nokogiri::XML::Builder.new(encoding: "UTF-8") do |builder|
      builder.urlset(xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9") do
        PublicDiscovery::PAGES.each_key do |path|
          builder.url { builder.loc "#{PublicDiscovery::ORIGIN}#{path}" }
        end
      end
    end
    render xml: xml.to_xml
  end

  def llms
    lines = [ "# News Jace Pro", "", "> An independent ServiceNow news aggregator and ecosystem directory.", "", "External articles belong to their original publishers. Follow source links for original reporting.", "", "## Public directories", "" ]
    PublicDiscovery::PAGES.each do |path, (title, description)|
      lines << "- [#{title}](#{PublicDiscovery::ORIGIN}#{path}): #{description}"
    end
    lines << "\nSitemap: #{PublicDiscovery::ORIGIN}/sitemap.xml"
    render plain: lines.join("\n") + "\n"
  end
end
