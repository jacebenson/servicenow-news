# A fixed, small directory catalog. Discovery never enumerates database records.
module PublicDiscovery
  ORIGIN = "https://news.jace.pro".freeze
  PAGES = {
    "/" => [ "ServiceNow news and ecosystem search", "Search collected ServiceNow news, partners, applications, financial activity, events, sessions, and MVP awards." ],
    "/i" => [ "ServiceNow news", "Browse ServiceNow articles, videos, and podcasts collected from external sources. Follow the source links to read the originals." ],
    "/p" => [ "ServiceNow partners", "Browse the ServiceNow partner directory and filter companies by services, partner level, and location." ],
    "/a" => [ "ServiceNow Store applications", "Browse the collected ServiceNow Store application directory by company, application type, and availability." ],
    "/financials" => [ "ServiceNow financial activity", "Explore ServiceNow acquisitions, investments, and company filings collected from public sources." ],
    "/e" => [ "ServiceNow events and sessions", "Browse Knowledge and other event session collections, speakers, and available recordings." ],
    "/mvps" => [ "ServiceNow MVP awards", "Explore ServiceNow community MVP award recipients and awards by year and type." ]
  }.freeze
end
