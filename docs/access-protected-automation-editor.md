# Protecting an automation editor without breaking webhooks

The automation service uses an outbound Cloudflare Tunnel. A tunnel publishes
the service but does not authenticate visitors, so its editor now has a
Cloudflare Access application with a policy limited to the administrator.
The application still requires its own login after Access.

Existing integrations need inbound webhooks. A single public path override for
`/webhook/*` preserves those calls; editor, API, and test-webhook paths remain
behind Access. Workflows that expose site pages also validate the site's own
Access token, so the public override does not grant access to those pages.

The change was verified from an unauthenticated client: editor and API requests
redirected to Access, a test-webhook request was protected, a production
webhook still reached the application, and the site's gated webhook still
returned its denial page without a valid token. An existing scheduled workflow
and a live page workflow completed after the application update.

The application image is pinned to a tested release rather than a moving tag.
Database and configuration backups were validated before the update.
