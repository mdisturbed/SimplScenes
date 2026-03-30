# SimplScenes Phase 2 — Video Asset Integration Plan

**Status:** In Progress (Infrastructure Complete)  
**Date:** March 30, 2026  
**Assignee:** Westley 🏴‍☠️

## Completed (Phase 1)
- ✅ App skeleton with SwiftUI UI, dark mode
- ✅ tvOS focus navigation and remote controls
- ✅ StoreKit2 IAP integration (4 scene packs)
- ✅ AVPlayer video playback infrastructure
- ✅ Scene manager with 15 scenes (10 free, 5 premium)

## Completed (Phase 2a — Infrastructure)
- ✅ VideoAssetManager module for centralized video URL management
- ✅ Dynamic URL resolution (CDN → fallback → local cache)
- ✅ SceneItem computed property for video URLs
- ✅ Async video loading in ScenePlayerView
- ✅ tvOS-compatible imports

## Phase 2b — Video Assets (Next Steps)

### Option A: Stock Footage (Recommended for Launch)
**Pros:** Fast, cost-effective, proven quality  
**Cons:** Generic ambient videos  
**Timeline:** 1-2 days  
**Cost:** $0-200/month for stock service

- Use Pexels, Pixabay, or Storyblocks for 4K ambient footage
- Download 15 clips (10 free, 5 premium scenes)
- Encode to H.265 HEVC (better compression for tvOS)
- Host on S3 or CDN
- Update VideoAssetManager.videoBaseURL to CDN endpoint

**Scenes:**
- Free: Ocean Waves, Forest Rain, Fireplace, Northern Lights, Desert Sunset, Mountain Stream, City Night, Cherry Blossoms, Thunderstorm, Starfield
- Premium: Arctic Aurora, Tropical Paradise, Space Nebula, Volcano Eruption, Ocean Shipwreck

### Option B: AI Video Generation (Future Enhancement)
**Pros:** Custom, branded, unique content  
**Cons:** Slower, requires API credits, less predictable  
**Timeline:** 3-5 days  
**Cost:** $100-300 for initial generation

- Use RunwayML or other AI video API
- Generate with Crafted Music House artist soundtracks
- Encode and host

### Phase 2b Deliverables
1. 15x 4K (or 2K) HEVC video files (10-60 seconds each)
2. CDN endpoint with HTTPS and caching headers
3. VideoAssetManager.videoBaseURL = actual CDN URL
4. App signed and ready for TestFlight

### Phase 2c — TestFlight Submission
**Prerequisites:**
- App created in ASC (com.sudobuiltapps.simplscenes)
- Videos hosted and accessible
- Signing profiles configured
- Compliance documentation complete (data privacy)

**Steps:**
1. Update Bundle ID in Xcode (hardcoded for now: com.sudobuiltapps.simplscenes)
2. `xcodebuild archive -scheme SimplScenes`
3. Validate archive with notarization
4. Upload to TestFlight via ASC or transporter
5. Add testers (default: willy-wally@outlook.com)
6. Expire old builds

**Timeline:** 1-2 days (pending video assets)

## Decision Points
- [ ] Which stock footage service? (Pexels/Pixabay = free, Storyblocks = $200/mo)
- [ ] Encode to H.265 HEVC, HEVC Main 10, or ProRes? (H.265 recommended for file size)
- [ ] Where to host? (S3, Bunny CDN, Fastly, or appleflix Docker)
- [ ] How to sync videos post-launch? (App update with new IAP packs)

## Success Criteria
✅ All 15 scenes have working video playback  
✅ Videos stream without buffering on Simulator + real Apple TV  
✅ Dark theme maintained  
✅ TestFlight build ready for review  
✅ IAP packs unlock premium scenes  
