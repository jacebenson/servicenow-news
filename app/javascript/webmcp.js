const TOOL_ANNOTATIONS = {
  readOnlyHint: true,
  untrustedContentHint: true,
  consequentialHint: false
};

const stringProperty = (description) => ({ type: "string", description });

const searchSchema = (properties) => ({
  type: "object",
  properties,
  additionalProperties: false
});

const navigate = (path) => {
  const url = new URL(path, window.location.origin);
  if (window.Turbo) {
    window.Turbo.visit(url.toString());
  } else {
    window.location.assign(url.toString());
  }

  return { url: url.toString(), message: `Opened ${url.pathname}${url.search}` };
};

const queryPath = (path, values) => {
  const params = new URLSearchParams();
  Object.entries(values).forEach(([key, value]) => {
    if (value !== undefined && value !== null && String(value).trim() !== "") {
      params.set(key, String(value).trim());
    }
  });
  const query = params.toString();
  return query ? `${path}?${query}` : path;
};

const tools = [
  {
    name: "search_service_now",
    title: "Search News Jace Pro",
    description: "Search the complete maintained ServiceNow index across news, partners, applications, financial activity, events, sessions, and MVPs.",
    inputSchema: searchSchema({
      query: { ...stringProperty("Words or phrases to search for."), minLength: 1 },
      type: { type: "string", enum: ["news_item", "partner", "application", "financial", "knowledge_session", "mvp", "participant"], description: "Optional result category." }
    }),
    execute: async ({ query, type }) => navigate(queryPath("/s", { q: query, type }))
  },
  {
    name: "search_news_items",
    title: "Search news and community items",
    description: "Find active ServiceNow news articles, videos, podcasts, and other indexed source material.",
    inputSchema: searchSchema({
      search: stringProperty("Words or phrases in the title, body, URL, or participant name."),
      participant: stringProperty("Participant slug to limit results to.")
    }),
    execute: async ({ search, participant }) => navigate(queryPath("/i", { search, participant }))
  },
  {
    name: "search_partners",
    title: "Search ServiceNow partners",
    description: "Find active partner companies and filter them by name, location, partner level, or whether they have people linked.",
    inputSchema: searchSchema({
      search: stringProperty("Company name, note, city, state, or country."),
      level: stringProperty("Partner level."),
      country: stringProperty("Country."),
      state: stringProperty("State or region."),
      has_people: { type: "boolean", description: "Only show partners with linked people." }
    }),
    execute: async ({ search, level, country, state, has_people }) => navigate(queryPath("/p", {
      search, level, country, state, has_people: has_people ? "true" : undefined
    }))
  },
  {
    name: "search_applications",
    title: "Search ServiceNow Store applications",
    description: "Find applications in the ServiceNow Store index and filter by company, type, price, trial, licensing, instance availability, or reviews.",
    inputSchema: searchSchema({
      search: stringProperty("Application title, tagline, or description."),
      company: stringProperty("Publisher or company name."),
      app_type: stringProperty("Application type."),
      price: { type: "string", enum: ["free", "paid"], description: "Free or paid applications." },
      trial: { type: "boolean", description: "Only applications offering a trial." },
      no_license: { type: "boolean", description: "Only applications usable without a license." },
      dev_instance: { type: "boolean", description: "Only applications available on developer instances." },
      prod_instance: { type: "boolean", description: "Only applications available on ServiceNow instances." },
      min_reviews: { type: "integer", minimum: 0, description: "Minimum review count." }
    }),
    execute: async ({ search, company, app_type, price, trial, no_license, dev_instance, prod_instance, min_reviews }) => navigate(queryPath("/a", {
      search, company, app_type, price,
      trial: trial ? "1" : undefined,
      no_license: no_license ? "1" : undefined,
      dev_instance: dev_instance ? "1" : undefined,
      prod_instance: prod_instance ? "1" : undefined,
      min_reviews
    }))
  },
  {
    name: "search_financial_activity",
    title: "Search ServiceNow financial activity",
    description: "Find acquisitions, investments, and SEC-related financial activity indexed by News Jace Pro.",
    inputSchema: searchSchema({
      search: stringProperty("Company name, summary, or filing content."),
      type: stringProperty("Investment type, such as Acquisition or Investment."),
      year: { type: "integer", minimum: 1900, maximum: 9999, description: "Four-digit year." }
    }),
    execute: async ({ search, type, year }) => navigate(queryPath("/financials", { search, type, year }))
  },
  {
    name: "search_mvp_awards",
    title: "Search ServiceNow MVP awards",
    description: "Find ServiceNow MVP recipients and filter awards by name, company, year, or award type.",
    inputSchema: searchSchema({
      search: stringProperty("Person name, title, or company."),
      year: { type: "integer", minimum: 1900, maximum: 9999, description: "Award year." },
      award_type: stringProperty("Award type.")
    }),
    execute: async ({ search, year, award_type }) => navigate(queryPath("/mvps", { search, year, award_type }))
  },
  {
    name: "search_people",
    title: "Search ServiceNow people",
    description: "Find visible people indexed by name, title, or company and open their public profile.",
    inputSchema: searchSchema({
      search: stringProperty("Person name, title, or company.")
    }),
    execute: async ({ search }) => navigate(queryPath("/w", { search }))
  },
  {
    name: "open_news_item",
    title: "Open a news item",
    description: "Open a specific news item by its numeric News Jace Pro ID.",
    inputSchema: searchSchema({ id: { type: "integer", minimum: 1, description: "News item ID." } }),
    execute: async ({ id }) => navigate(`/i/${encodeURIComponent(id)}`)
  },
  {
    name: "open_application",
    title: "Open a Store application",
    description: "Open a specific ServiceNow Store application by its numeric News Jace Pro ID.",
    inputSchema: searchSchema({ id: { type: "integer", minimum: 1, description: "Application ID." } }),
    execute: async ({ id }) => navigate(`/a/${encodeURIComponent(id)}`)
  },
  {
    name: "open_partner",
    title: "Open a partner profile",
    description: "Open a specific active partner profile by its numeric News Jace Pro ID.",
    inputSchema: searchSchema({ id: { type: "integer", minimum: 1, description: "Partner company ID." } }),
    execute: async ({ id }) => navigate(`/p/${encodeURIComponent(id)}`)
  },
  {
    name: "open_person",
    title: "Open a person profile",
    description: "Open a public person profile by its News Jace Pro slug.",
    inputSchema: searchSchema({ slug: { type: "string", minLength: 1, description: "Person profile slug." } }),
    execute: async ({ slug }) => navigate(`/who/${encodeURIComponent(slug)}`)
  }
];

const registerTools = async () => {
  if (!window.isSecureContext || !document.modelContext?.registerTool) return;

  for (const tool of tools) {
    try {
      await document.modelContext.registerTool({ ...tool, annotations: TOOL_ANNOTATIONS });
    } catch (error) {
      // Keep WebMCP a progressive enhancement if a browser rejects one tool.
      console.warn(`WebMCP could not register ${tool.name}`, error);
    }
  }
};

registerTools();
