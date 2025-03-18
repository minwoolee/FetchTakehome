### Summary: Include screen shots or a video of your app highlighting its features
<img src="https://github.com/user-attachments/assets/e745ced7-df71-4119-bcea-fc802ad7789e" alt="screenshot" width="200"/>
<img src="https://github.com/user-attachments/assets/ed32bd4b-51c5-43c7-a7b0-dacb0f7d87a4" alt="screenshot"/>


### Focus Areas: What specific areas of the project did you prioritize? Why did you choose to focus on these areas?
1. Handling different app states (empty, error, success)
2. Caching remote images to disk and being able to clear disk cache when pull-to-refresh
3. Testing

### Time Spent: Approximately how long did you spend working on this project? How did you allocate your time?
I spent about 7 hours over the course of 3 days.

### Trade-offs and Decisions: Did you make any significant trade-offs in your approach?
Not significant, but I've chose to keep `CachedImageViewModel` in the same file as `CachedImage` as it is self contained reusable component and is not related to the app logic.

### Weakest Part of the Project: What do you think is the weakest part of your project?
Overall app design is very barebones. If given more time, I would prefer to use SFSafariViewController instead of `openURL` SwiftUI action, to open URL's.
Also, I could have used more animations and transition effects for more user delight.

### Additional Information: Is there anything else we should know? Feel free to share any insights or constraints you encountered.
- For persisting downloaded images to disk, I've decided to use MD5 cache of the URL for stable hashing across app launches and it appears to be working well.
- Disk cache does not automatically expire (it's another area for improvement if there were more time), however, pull-to-refresh will clear disk cache.
