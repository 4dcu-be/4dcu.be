# Translating posts into Dutch

English remains the default language and keeps its existing URLs. Dutch posts live under `_posts/nl/` and are published below `/nl/`.

To link a translation to its English original, add the same stable `post_id` to both files:

```yaml
post_id: game-boy-sound-generator
```

The rest of the front matter can be translated normally. Keep `post_id` language-neutral and unique. The matching ID creates the language-switcher link and reciprocal `hreflang` annotations. A post without a translated counterpart is only advertised in the language in which it exists.

Example paths:

```text
_posts/2026/2026-08-12-example.md       # English original
_posts/nl/2026-08-12-example.md         # Dutch translation
```

Dutch posts automatically receive `locale: nl_NL`, Dutch archive links, a Dutch RSS feed, and a URL below `/nl/`. Do not add `locale` or `permalink` manually unless a post needs an exceptional URL.
