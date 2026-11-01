xml.instruct! :xml, version: "1.0", encoding: "UTF-8"
xml.urlset xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9" do
  @paths.each { |path| xml.url { xml.loc "#{PublicIndexing::ORIGIN}#{path}" } }
end
