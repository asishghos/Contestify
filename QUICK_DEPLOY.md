# Quick Deploy to Vercel

## ⚡ Fastest Way: Pre-build and Deploy (Recommended)

### Step 1: Build Locally
```bash
cd code_hub
flutter build web --release
```

### Step 2: Deploy to Vercel

**Option A: Via Vercel CLI**
```bash
# Install Vercel CLI
npm i -g vercel

# Login
vercel login

# Deploy (from project root)
vercel --prod
```

**Option B: Via Vercel Dashboard**
1. Push your code to GitHub
2. Go to [vercel.com](https://vercel.com)
3. Import your repository
4. Set Output Directory: `code_hub/build/web`
5. Deploy!

**Option C: Use GitHub Actions (Automatic)**
1. Get Vercel tokens from Vercel dashboard
2. Add as GitHub Secrets:
   - `VERCEL_TOKEN`
   - `VERCEL_ORG_ID`
   - `VERCEL_PROJECT_ID`
3. Push to GitHub - auto-deploys! 🚀

See `.github/workflows/deploy-vercel.yml` for the workflow.

---

## Via GitHub (Recommended for CI/CD)

1. Push your code to GitHub
2. Go to [vercel.com](https://vercel.com)
3. Click "Add New Project"
4. Import your repository
5. Vercel will auto-detect the configuration
6. Click "Deploy"

---

## Verify Build Locally First

Before deploying, test the build:

```bash
cd code_hub
flutter build web --release
```

If this works, Vercel deployment will work too!

---

## Troubleshooting

**"Flutter not found" error:**
- Vercel needs Flutter installed in the build environment
- You may need to use a custom build image or install Flutter in the build command
- Alternative: Use GitHub Actions to build and deploy

**Build timeout:**
- Flutter builds can take time
- Consider using Vercel's Pro plan for longer build times

**404 errors on routes:**
- The `vercel.json` already handles this with rewrites
- If issues persist, check the rewrites configuration

---

## Next Steps

- Add custom domain in Vercel dashboard
- Set up environment variables for API keys
- Enable Vercel Analytics for monitoring

