xml.instruct! :xml, version: "1.0", encoding: "UTF-8"
xml.sitemapindex xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9" do
  @sitemaps.each { |url| xml.sitemap { xml.loc url } }
end
