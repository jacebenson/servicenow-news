# News Jace Pro domain glossary

## Product

News Jace Pro is a maintained ServiceNow index. Its job is to help a visitor find something about ServiceNow and understand it, using records maintained in the site's own database.

It is not a general web search engine, a complete ServiceNow documentation mirror, or a replacement for the ServiceNow community. It is a curated, searchable index of useful ServiceNow ecosystem information.

## Record types

- Item: a news or community item, including articles, videos, and podcasts.
- Partner: a public company or organization associated with ServiceNow's partner ecosystem.
- Company: an internal company record with richer administrative data. Companies are admin-only in public search and navigation.
- Application: a ServiceNow Store application.
- Financial activity: an acquisition, investment, SEC filing, or related financial/company event.
- Event: a conference or event collection containing sessions.
- Session: a talk or presentation belonging to one event. A session has no standalone public identity outside its event.
- MVP: an MVP award or MVP-related public record.
- Person: a participant or speaker. People are admin-only in search and navigation.

## Search

Global search covers the full local index only. It never fetches external sources when the local index has no match.

Search ranking, from strongest to weakest:

1. Exact title or name match
2. Exact phrase match
3. Prefix or strong name/title match
4. Summary match
5. Related metadata match
6. Full content/body match
7. URL or source-text match

When a query exactly matches multiple records, show them together in an Exact matches section. Do not arbitrarily choose one record.

Search results are grouped by the matching thing or record type. Compact sections show a useful limited set and the total count, with a link to the complete filtered result set. Relevance comes before recency; recency breaks ties.

Search results show a short excerpt around a content match, identify the matching record type and field, highlight the matched phrase, and make the destination clear.

No-result responses show the exact query, explain that it was not found in the local index, suggest broader or related searches, and link to browseable record types. They do not silently search the web.

Search queries and filters are preserved in shareable URLs.

## Visibility

Public search includes items, partners, applications, financial activity, events/sessions, and MVPs.

People and companies remain admin-only. They may appear in admin search but not anonymous results, public navigation, or public result counts.

## Navigation

The preferred public route shape is short and consistent:

- `/` — search-first orientation and entry point
- `/s` — global search
- `/i` — items/news
- `/p` — partners
- `/a` — applications
- `/f` — financial activity
- `/e` — event and session index
- `/e/:event_slug` — one event
- `/e/:event_slug/:session_slug` — one session within its event
- `/m` — MVPs
- `/c` — admin-only companies
- `/w` — admin-only people

Existing URLs should redirect to the new canonical routes where they can be mapped safely.

## Link behavior

News items normally open their original article, video, or podcast because that is the useful destination. Other record types normally open their local News Jace Pro record first, with the original source as a secondary verification link.

Every result makes its destination explicit, such as “Watch on YouTube,” “Read source,” “Open company profile,” or “View session.”

## Filtering

The first filter layer is lightweight type chips with counts. Selecting a type reveals contextual filters inline, never in a side panel.

Examples:

- Partners: partner levels
- MVPs: award year and award type
- Events: event name and tags
- Financial activity: activity type and year
- Applications: application type and company

Contextual filters are URL-addressable and shareable. Only filters relevant to the current result set need to appear.
