xml.instruct! :xml, version: "1.0", encoding: "UTF-8"
xml.urlset xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9" do
  @records.each do |record|
    path = case @type
    when "news" then item_path(record)
    when "partners" then partner_path(record)
    when "applications" then application_path(record)
    when "people"
      next if record.slug.blank?
      person_path(name: record.slug)
    end
    xml.url do
      xml.loc "#{PublicIndexing::ORIGIN}#{path}"
      xml.lastmod record.updated_at.utc.iso8601
    end
  end
end
