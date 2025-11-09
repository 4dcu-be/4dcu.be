# Jekyll 3.10 → 4.4.1 Upgrade Progress

## Upgrade Strategy
- Ruby version: 3.3.6 (latest stable)
- Jekyll version: 4.4.1
- Sass strategy: Upgrade to Dart Sass (sass-embedded)
- Approach: Full upgrade in one go

---

## COMPLETED STEPS ✅

### 1. Environment Setup
- [x] Updated `.ruby-version` from 2.6.3 to 3.3.6
- [x] Backed up `Gemfile.lock` to `Gemfile.lock.backup`

### 2. Dependency Updates
- [x] Updated `Gemfile`:
  - Changed Jekyll from `<4` to `~> 4.4.1`
  - Added `jekyll-sass-converter ~> 3.0`
  - Added `sass-embedded ~> 1.77` (Dart Sass)
  - Removed old `sass` gem dependency (Ruby Sass - deprecated)

### 3. Dockerfile Updates
- [x] Changed base image from `ruby:2.6.3-slim-buster` to `ruby:3.3.6-slim-bookworm`
- [x] Removed obsolete Debian archive workarounds (Bookworm is current)
- [x] Updated Bundler installation for Ruby 3.3.6 compatibility

---

## NEXT STEPS (After Container Rebuild) 🔄

### IMMEDIATE: Rebuild Container
**ACTION REQUIRED:** Rebuild the devcontainer before proceeding
- In VS Code: `F1` → "Dev Containers: Rebuild Container"
- This will install Ruby 3.3.6 and all system dependencies

### Phase 1: Install Updated Dependencies
```bash
# Run bundle update to install Jekyll 4.4.1 and all updated gems
bundle update

# Verify versions
ruby --version    # Should show 3.3.6
jekyll --version  # Should show 4.4.1
bundle list       # Check all gem versions
```

### Phase 2: Configuration Review
- [ ] Review `_config.yml` exclude settings
  - Jekyll 4 changed behavior: user excludes are now ADDED to defaults, not replacing them
  - May need to adjust if you have custom excludes
- [ ] Review `_config_dev.yml` exclude settings
- [ ] Check for any deprecated configuration options

### Phase 3: Test Custom Plugins (HIGH PRIORITY)
Test all 6 custom plugins for Jekyll 4 compatibility:

#### Low Risk (Generators - likely compatible):
- [ ] `_plugins/thumbnail_generator.rb` - Test thumbnail generation
- [ ] `_plugins/gallery_generator.rb` - Test gallery creation
- [ ] `_plugins/json_featured.rb` - Test JSON output

#### Medium Risk (Hooks - need careful testing):
- [ ] `_plugins/lightgallery_links.rb` - Uses `pre_render` hook with content modification
  - **Risk:** Jekyll 4 changed template parsing/caching behavior
  - **Test:** Verify gsub! operations on post.content still work
- [ ] `_plugins/vegachart_tags.rb` - Uses `pre_render` hook
  - **Risk:** Same template caching concerns
  - **Test:** Verify Vega chart rendering
- [ ] `_plugins/image_size.rb` - Uses `pre_render` hook with Jekyll.sites.first.source
  - **Risk:** Uses less common API patterns
  - **Test:** Verify image size detection works

### Phase 4: Test SCSS/Sass Compilation (CRITICAL)
**Your project uses Bourbon/Neat framework extensively** - Dart Sass compatibility is critical:

```bash
# Test development build
bundle exec jekyll serve --config _config_dev.yml --incremental --port 5000

# Watch for SCSS compilation errors
# Check browser console for CSS issues
```

**What to check:**
- [ ] All SCSS files compile without errors
- [ ] Bourbon mixins work with Dart Sass
- [ ] Neat grid system functions correctly
- [ ] @import statements resolve properly
- [ ] Compiled CSS matches expected output
- [ ] Visual appearance matches original design
- [ ] Responsive breakpoints work correctly

**Common Dart Sass issues to watch for:**
- Division operator: Use `math.div()` instead of `/` for calculations
- Color functions: Some older functions may need updates
- Import paths: `@import` vs `@use` syntax

### Phase 5: Test Build Process

#### Development Build:
```bash
bundle exec jekyll serve --config _config_dev.yml --incremental --port 5000
```
- [ ] Build completes without errors
- [ ] Server starts on port 5000
- [ ] Navigate to http://localhost:5000
- [ ] Check homepage loads correctly
- [ ] Check several blog posts render
- [ ] Verify images and thumbnails display

#### Production Build:
```bash
bundle exec jekyll build --config _config.yml
```
- [ ] Build completes without errors
- [ ] Output directory (`./docs`) populated correctly
- [ ] Run Pagefind: `pagefind` or `.\pagefind.exe`
- [ ] Verify search index created

### Phase 6: Comprehensive Feature Testing

#### Core Features:
- [ ] **Pagination** - Navigate through blog post pages (7 posts per page)
- [ ] **Archives**
  - [ ] Category archives work
  - [ ] Tag archives work
  - [ ] Year-based archives work
- [ ] **Search** - Pagefind search functionality works
- [ ] **Images**
  - [ ] Cover images display correctly
  - [ ] Thumbnails generated (430x288 dimensions)
  - [ ] LightGallery integration works
  - [ ] Image galleries function
- [ ] **Social Sharing** - BlueSky, Facebook, LinkedIn, X links work
- [ ] **Responsive Design** - Mobile/tablet layouts work
- [ ] **AOS Animations** - Animate on Scroll works

#### Content Validation:
- [ ] Test posts from different categories:
  - [ ] programming
  - [ ] games
  - [ ] diy
  - [ ] biology
  - [ ] general
- [ ] Verify post_url links work (46+ files use this tag)
  - Jekyll 4 auto-includes relative_url filter
  - May need manual review if issues arise
- [ ] Check code syntax highlighting (Rouge)
- [ ] Verify Markdown rendering (kramdown-parser-gfm)

### Phase 7: Performance & Validation
- [ ] Run full production build with timing
- [ ] Check build performance vs Jekyll 3.10
- [ ] Validate HTML output (no broken links)
- [ ] Test in multiple browsers
- [ ] Verify GitHub Pages compatibility (build to ./docs works)

---

## TROUBLESHOOTING GUIDE

### If Bundle Update Fails:
```bash
# Check Ruby version
ruby --version  # Must be >= 2.7.0

# Try bundle install first
bundle install

# If still failing, remove lock and try again
rm Gemfile.lock
bundle install
```

### If SCSS Compilation Fails:
1. Check error messages for specific Sass syntax issues
2. Common fixes:
   - Replace `/` division with `math.div()` or `calc()`
   - Update deprecated color functions
   - Check @import paths
3. Reference: https://sass-lang.com/documentation/breaking-changes/

### If Custom Plugins Fail:
1. Check plugin error messages in build output
2. For hooks that modify content:
   - Verify `gsub!` operations still work on `post.content`
   - May need to modify approach due to template caching
3. For generators:
   - Verify `site.posts.docs` API still works
   - Check `Jekyll.configuration({})` calls

### If Images Don't Generate:
1. Verify ImageMagick installed: `convert --version`
2. Check MiniMagick gem works: `bundle exec irb -r mini_magick`
3. Test thumbnail_generator.rb in isolation

---

## ROLLBACK PLAN (If Needed)

If the upgrade fails and you need to rollback:

```bash
# Restore original Gemfile.lock
cp Gemfile.lock.backup Gemfile.lock

# Revert Gemfile
# Change line 2 back to: gem 'jekyll', '<4'
# Remove jekyll-sass-converter and sass-embedded lines

# Revert .ruby-version
# Change back to: 2.6.3

# Revert Dockerfile
# Change line 2 back to: FROM ruby:2.6.3-slim-buster
# Restore Buster EOL workarounds
# Restore old Bundler installation

# Rebuild container
# F1 → "Dev Containers: Rebuild Container"

# Run bundle install
bundle install
```

---

## REFERENCE: Dependency Versions

### Current (Pre-Upgrade):
- Ruby: 2.6.3
- Jekyll: 3.10.0
- jekyll-sass-converter: 1.5.2
- sass: 3.7.4 (Ruby Sass)
- jekyll-archives: 2.2.1
- jekyll-paginate-v2: 3.0.0
- kramdown: 2.5.1
- rouge: 3.30.0

### Target (Post-Upgrade):
- Ruby: 3.3.6
- Jekyll: 4.4.1
- jekyll-sass-converter: 3.0.x
- sass-embedded: 1.77.x (Dart Sass)
- jekyll-archives: 2.2.1+ (already compatible)
- jekyll-paginate-v2: 3.0.0+ (already compatible)
- kramdown: Latest compatible
- rouge: Latest 4.x

---

## KNOWN RISKS & CONCERNS

### HIGH RISK:
1. **Bourbon/Neat Sass Framework**
   - Your project uses extensive Bourbon imports
   - Dart Sass may have compatibility issues
   - Thoroughly test all SCSS compilation

2. **Custom Hooks with Content Modification**
   - `lightgallery_links.rb` and `vegachart_tags.rb` use `gsub!` on content
   - Jekyll 4 changed template parsing/caching
   - May affect content modification in hooks

### MEDIUM RISK:
1. **post_url Tag Changes**
   - Jekyll 4 auto-includes relative_url filter
   - 46+ files use this tag
   - May need manual review if URLs break

2. **ImageMagick Operations**
   - Should work but test thumbnail generation thoroughly

### LOW RISK:
1. Generator plugins (already use stable APIs)
2. Configuration files (minimal changes needed)
3. Core Jekyll features

---

## SUCCESS CRITERIA

The upgrade is successful when:
- ✅ Ruby 3.3.6 installed and working
- ✅ Jekyll 4.4.1 installed and working
- ✅ Dart Sass (sass-embedded) compiling all SCSS without errors
- ✅ All 6 custom plugins working correctly
- ✅ Development server runs without errors
- ✅ Production build completes successfully
- ✅ Pagefind search indexing works
- ✅ All site features tested and functional
- ✅ Visual appearance matches original design
- ✅ No console errors in browser
- ✅ Responsive design works on all devices

---

## HELPFUL COMMANDS

```bash
# Check versions
ruby --version
jekyll --version
bundle list | grep jekyll
gem list sass

# Development server
bundle exec jekyll serve --config _config_dev.yml --incremental --port 5000

# Production build
bundle exec jekyll build --config _config.yml && pagefind

# Clean build
bundle exec jekyll clean
bundle exec jekyll build --config _config.yml

# Debug build with verbose output
bundle exec jekyll build --config _config.yml --verbose

# Check for deprecation warnings
bundle exec jekyll build --config _config.yml 2>&1 | grep -i deprecat

# Test specific plugin
bundle exec ruby _plugins/thumbnail_generator.rb
```

---

## DOCUMENTATION LINKS

- Jekyll 4.x Documentation: https://jekyllrb.com/docs/
- Jekyll 3 to 4 Migration: https://jekyllrb.com/docs/upgrading/3-to-4/
- Sass Migration Guide: https://sass-lang.com/documentation/breaking-changes/
- Dart Sass: https://sass-lang.com/dart-sass
- Bourbon Documentation: https://www.bourbon.io/docs/latest/
- jekyll-archives: https://github.com/jekyll/jekyll-archives
- jekyll-paginate-v2: https://github.com/sverrirs/jekyll-paginate-v2

---

**Last Updated:** 2025-11-09
**Status:** Ready for container rebuild and bundle update
**Next Action:** Rebuild devcontainer in VS Code
