# ADR 0001: Make the product search-first

Status: Accepted

## Context

News Jace Pro began as a better way to browse ServiceNow news than the ServiceNow community site. Its maintained data has since expanded to include partners, applications, financial activity, events and sessions, MVPs, people, and companies.

Treating each dataset as a separate sub-product creates separate navigation models and forces visitors to guess where information lives. The current user need is usually retrieval: finding a past session, application detail, acquisition, financial event, or buried community/blog item.

The site must remain bounded by its own maintained database. It should not become an on-demand web crawler.

## Decision

Make News Jace Pro a search-first maintained ServiceNow index.

The root page provides a real global search box and explains the record types available. `/s` provides the full global search experience. Existing collection routes remain useful for browsing one record type.

Search covers the full local index with weighted ranking. Exact entity/title matches outrank phrase, prefix, summary, metadata, content, and URL matches. Results are grouped, limited sections with counts and links to complete result sets. Search excerpts explain why a result matched. Search URLs preserve queries and filters.

Public and admin visibility remain separate. People and companies are not exposed to anonymous users.

Short route names are canonical for public collections, with event/session nesting under `/e`. Existing routes redirect where safely mappable.

## Consequences

Positive:

- Visitors can start with the question they have instead of choosing a dataset first.
- The data model becomes coherent: different sources are record types in one index.
- Search results can connect a company to its news, financial activity, sessions, applications, and MVP records.
- Existing collection pages remain useful as browse surfaces.
- Local-only search keeps latency, ranking, and source boundaries predictable.

Costs and follow-up:

- Search requires a cross-model index or coordinated query layer.
- Each record type needs a clear public/admin visibility rule.
- Ranking and excerpts need deterministic tests.
- Existing URLs need redirect mappings during route migration.
- The root page and current news feed should not be redesigned around a feed until search works.
