# GitHub Actions Workflows

## Gemini PR Review

Automatically review pull requests using Google's Gemini AI.

### Setup

1. **Add API Key to GitHub Secrets:**
   - Go to your repository Settings → Secrets and variables → Actions
   - Add the following secret:
     - `GEMINI_API_KEY` - Your Google Gemini API key (get from https://aistudio.google.com/app/apikey)

### Usage

#### How to Trigger a Review
1. Add the `ai-review` label to your pull request
2. Gemini will automatically review the code
3. Review results will be posted as a PR comment
4. The label will be automatically removed after the review completes

**Note:** Reviews will not run on draft PRs.

#### How to Add the Label
- In GitHub UI: Click the "Labels" section on the right side of the PR → select `ai-review`
- Or via CLI: `gh pr edit <PR#> --add-label "ai-review"`

### Review Criteria

Gemini reviews code based on:
- ✅ Code quality and best practices
- ✅ Potential bugs or issues
- ✅ Performance considerations
- ✅ Security implications
- ✅ Rails conventions and SOLID principles
- ✅ Test coverage
- ✅ Documentation needs

### Customization

Edit `.github/workflows/ai-code-review.yml` to modify:
- AI model (default: `gemini-2.5-flash`)
- Review criteria and focus areas
- Token limits
- Review language (currently: English)

### Troubleshooting

**If the review doesn't run:**
- Verify the `ai-review` label is correctly added
- Confirm the PR is not in draft state
- Check that `GEMINI_API_KEY` is properly configured

**If API errors occur:**
- Verify your Gemini API key is valid
- Check if you've reached API rate limits
- If the PR changes are too large, consider splitting into multiple commits

## Issue & PR Bot

Automatically respond to GitHub issues and pull requests, and apply code fixes using Gemini AI.

### Setup

Requires the same `GEMINI_API_KEY` secret as above.

### Usage

#### How to Trigger the Bot
The bot activates on:
1. **Issues labeled with `bot`** - The bot will respond to any comments on these issues
2. **Comments on issues from the repository owner** - Any comment from you (the owner) will trigger the bot
3. **New issues containing `@bot` in the body** - Mention `@bot` in new issue descriptions
4. **Pull requests labeled with `bot`** - The bot will respond to any comments on these PRs
5. **Comments on PRs from the repository owner** - Any comment from you (the owner) will trigger the bot
6. **New PRs containing `@bot` in the description** - Mention `@bot` in new PR descriptions

#### Bot Capabilities
- **General Questions:** Responds to questions and comments on issues/PRs
- **Code Fixes:** If a comment contains keywords like "fix", "correct", "update", "change", "rubocop", or "lint", the bot will:
  - Generate code changes using Gemini AI
  - Apply the changes to the repository automatically
  - Commit and push the fixes with detailed commit messages
  - Post the AI response as a comment with links to the changes

#### Example Usage
- **Label an issue with `bot`** and comment: "Please explain this code"
- **Comment as repo owner on an issue**: "Fix the bug in user.rb"
- **Create new issue** with `@bot` in the description: "Please review this feature @bot"
- **Label a PR with `bot`** and comment: "Please review these changes"
- **Comment as repo owner on a PR**: "Fix the linting errors"
- **Create new PR** with `@bot` in the description: "Please review this feature @bot"
- **Fix Rubocop issues**: "Fix the Rubocop offenses in this file"

The bot will analyze the request, generate appropriate responses or code changes, and commit them automatically.

### Troubleshooting

**If the bot doesn't respond:**
- **Check trigger conditions:** Make sure one of these is true:
  - Issue/PR is labeled with `bot` 
  - Comment is from repository owner
  - New issue/PR contains `@bot` in the description
- **Verify API key:** Ensure `GEMINI_API_KEY` is set in repository secrets
- **Check workflow runs:** Go to Actions tab to see if the workflow triggered
- **Look for error messages:** The bot will post error messages if something goes wrong

**Common issues:**
- Comments from non-owners won't trigger unless issue/PR is labeled `bot`
- Draft issues/PRs won't trigger the bot
- API rate limits may cause delays
- For code fixes, the bot expects specific formatting in AI responses
- If fixes don't apply, check that the AI provided correct old/new code with proper context

### Security Notes
- Only the repository owner can trigger fixes via comments on issues or PRs
- Issues/PRs must be labeled `bot` for general responses from other users
- All changes are committed with clear messages indicating they were bot-generated

To give your bot a custom name and avatar instead of using `github-actions[bot]`, create a GitHub App:

### 1. Create GitHub App
1. Go to **GitHub Settings** → **Developer settings** → **GitHub Apps**
2. Click **"New GitHub App"**
3. Fill in the details:
   - **GitHub App name**: `Kakeibo Assistant` (or your preferred name)
   - **Description**: `AI-powered code review and issue management bot`
   - **Homepage URL**: Your repository URL
   - Upload an **avatar image** (logo for your bot)

### 2. Configure Permissions
Set these repository permissions:
- **Contents**: Read and write
- **Issues**: Read and write  
- **Pull requests**: Read and write
- **Commit statuses**: Read and write (optional)

### 3. Generate Private Key
1. In the app settings, scroll to **"Private keys"**
2. Click **"Generate a private key"**
3. Download the `.pem` file

### 4. Install the App
1. In the app settings, go to **"Install App"**
2. Click **"Install"** next to your account/organization
3. Select the repository and click **"Install"**

### 5. Add Secrets to Repository
Go to your repository **Settings** → **Secrets and variables** → **Actions** and add:
- `APP_ID`: The App ID from the app settings page
- `PRIVATE_KEY`: The entire content of the downloaded `.pem` file
- `BOT_NAME`: Display name for commits (e.g., "Kakeibo Assistant") - *optional*
- `BOT_EMAIL`: Email for commits (e.g., "kakeibo-assistant[bot]@users.noreply.github.com") - *optional*

### 6. Update Workflows
Replace the GitHub App token generation steps in your workflows:

```yaml
- name: Generate GitHub App token
  id: app-token
  uses: actions/create-github-app-token@v2
  with:
    app-id: ${{ secrets.APP_ID }}
    private-key: ${{ secrets.PRIVATE_KEY }}

# Then use ${{ steps.app-token.outputs.token }} instead of ${{ secrets.GITHUB_TOKEN }}
```

### 7. Update Commit Author
In the commit steps, change to:
```yaml
git config --global user.name 'Kakeibo Assistant'
git config --global user.email 'kakeibo-assistant[bot]@users.noreply.github.com'
```

This will make all bot actions appear as coming from your custom bot with its name and avatar.

