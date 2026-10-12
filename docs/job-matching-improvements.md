# Personal job matching: Romanian coverage and contracting evidence

The job scanner now prioritizes Romanian opportunities and suitable contracting
work against the operator's stored professional profile and practical project
experience. Project experience does not imply enterprise seniority, and planned
certifications are not treated as earned qualifications.

Romanian telecom vacancies come directly from Vodafone's public career listings.
Published employer APIs add local network and infrastructure roles. Public
Freelancermap listings add genuine contractor opportunities, while existing
aggregators remain available for broader discovery. Sources retain their original
application links; the scanner never applies or contacts recruiters automatically.

Collection preserves skill requirements and contracting evidence found deeper
in descriptions. A company's legal suffix, B2B customer base, or fixed-term
employment contract does not establish B2B collaboration. Explicit freelance
status remains distinct from verified legal B2B terms. Generic “remote” also does
not establish permission to work from Romania; unclear eligibility is labeled.

Romanian listings receive a reserved selection budget and priority over foreign
discovery. Jobs are deduplicated across sources and scored in small batches.
All batches are validated and saved, fixing a bug that could discard later batches.
Invalid or incomplete scoring fails before database writes. The success heartbeat
follows completed storage, rather than firing before the collection/scoring work.

FreshRSS has separate feeds for Romanian matches and suitable B2B/contracts,
alongside the existing general feed. Entries explain fit, location, work mode,
contract evidence, missing skills, and publication date when supplied. Empty feeds
remain valid RSS and explain the lack of qualifying matches; weak roles are not
promoted to fill them. The weekly skill report now uses relevant, geographically
accessible matches rather than unrelated software postings.

Live verification covers real collection, AI scoring, every persisted batch,
valid RSS output, and reader subscriptions. Focused tests cover false B2B labels,
location eligibility, relevant-title filtering, deep requirements, and batch
validation. Existing subscriptions, provider switching and authentication remain
available. Workflow source and additive schema changes support repeatable repair.

Provider limitations remain visible: Jooble requires regional API credentials
and documents a finite free lifetime quota; a country name alone does not grant
access to another regional index. Public page layouts may also change, so failures
are retained as source diagnostics rather than claimed successful collection.

References: [SmartRecruiters Posting API](https://developers.smartrecruiters.com/docs/endpoints),
[Jooble API](https://jooblehelpcenter.freshdesk.com/en/support/solutions/articles/60001448238-rest-api-documentation),
and [Freelancermap](https://www.freelancermap.com/projects).

A subsequent operator-confirmed profile correction now emphasizes fixed voice
and data operations consistently in job scoring and weekly career guidance.
