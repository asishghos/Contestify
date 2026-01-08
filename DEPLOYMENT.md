# Vercel Deployment Guide for Flutter Web

This guide will help you deploy your Flutter web application to Vercel.

## Prerequisites

1. **Flutter SDK** installed and configured
2. **Vercel account** (sign up at [vercel.com](https://vercel.com))
3. **Git repository** (GitHub, GitLab, or Bitbucket)

## Deployment Steps

### ⚠️ Important Note
Vercel's default build environment doesn't include Flutter. You have two options:

**Option A: Pre-build and Deploy** (Easiest - Recommended)
**Option B: Use GitHub Actions** (For CI/CD)

---

### Option A: Pre-build and Deploy (Recommended)

1. **Build the Flutter web app locally**
   ```bash
   cd code_hub
   flutter build web --release
   ```

2. **Commit the build folder** (temporarily, or use .gitignore)
   ```bash
   # Option 1: Commit build (not recommended for large projects)
   git add code_hub/build/web
   git commit -m "Add pre-built web files"
   
   # Option 2: Use .vercelignore to exclude everything except build/web
   ```

3. **Update vercel.json for pre-built deployment**
   ```json
   {
     "version": 2,
     "outputDirectory": "code_hub/build/web",
     "rewrites": [
       { "source": "/(.*)", "destination": "/index.html" }
     ]
   }
   ```

4. **Deploy to Vercel**
   - Push to GitHub
   - Import to Vercel
   - Deploy (no build needed)

---

### Option B: Deploy via Vercel Dashboard (Requires Flutter in Build Environment)

**Note:** This requires Flutter to be available in Vercel's build environment. You may need to:
- Use a custom build image
- Install Flutter in the build command (slower, may timeout)
- Use GitHub Actions instead (see Option C)

1. **Push your code to GitHub/GitLab/Bitbucket**
   ```bash
   git add .
   git commit -m "Prepare for Vercel deployment"
   git push origin main
   ```

2. **Import Project to Vercel**
   - Go to [vercel.com](https://vercel.com)
   - Click "Add New Project"
   - Import your Git repository
   - Vercel will automatically detect the configuration from `vercel.json`

3. **Configure Build Settings** (if needed)
   - Framework Preset: Other
   - Build Command: `bash build.sh` (or `cd code_hub && flutter build web --release` if Flutter is available)
   - Output Directory: `code_hub/build/web`
   - Install Command: (leave empty, Flutter handles dependencies)

4. **Environment Variables** (if needed)
   - If you have API keys or secrets, add them in the Environment Variables section
   - For example, if you move the API key from `clist_api.dart` to environment variables:
     - Key: `CLIST_API_KEY`
     - Value: `your-api-key-here`

5. **Deploy**
   - Click "Deploy"
   - Wait for the build to complete
   - Your app will be live at `your-project.vercel.app`

### Option C: Use GitHub Actions (Best for CI/CD)

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to Vercel

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
          channel: 'stable'
      
      - name: Install dependencies
        run: |
          cd code_hub
          flutter pub get
      
      - name: Build web
        run: |
          cd code_hub
          flutter build web --release
      
      - name: Deploy to Vercel
        uses: amondnet/vercel-action@v25
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
          vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
          working-directory: code_hub/build/web
```

Then:
1. Get Vercel tokens from Vercel dashboard
2. Add them as GitHub Secrets
3. Push to GitHub - automatic deployment!

---

### Option D: Deploy via Vercel CLI (Pre-built)

1. **Install Vercel CLI**
   ```bash
   npm i -g vercel
   ```

2. **Login to Vercel**
   ```bash
   vercel login
   ```

3. **Deploy**
   ```bash
   vercel
   ```
   
   For production deployment:
   ```bash
   vercel --prod
   ```

## Configuration Details

The `vercel.json` file is already configured with:

- **Build Command**: Builds the Flutter web app in release mode
- **Output Directory**: Points to the Flutter web build output
- **Rewrites**: Handles client-side routing (SPA routing)
- **Headers**: Security headers and caching for optimal performance

## Important Notes

### Flutter Web Requirements

1. **Flutter SDK**: Make sure Flutter is installed on your system
   ```bash
   flutter --version
   ```

2. **Web Support**: Enable Flutter web support
   ```bash
   flutter config --enable-web
   ```

3. **Test Build Locally**: Before deploying, test the build locally
   ```bash
   cd code_hub
   flutter build web --release
   ```
   
   Then test the build:
   ```bash
   cd build/web
   # Use a local server like Python's http.server
   python -m http.server 8000
   ```

### Environment Variables

If you need to use environment variables (recommended for API keys):

1. **In Vercel Dashboard**:
   - Go to Project Settings → Environment Variables
   - Add your variables

2. **Update your code** to read from environment variables:
   - For Flutter web, you can use `dart:html` or a package like `flutter_dotenv`
   - Example: Replace hardcoded API key in `clist_api.dart` with environment variable

### Firebase Configuration

Your Firebase configuration is already set up in `web/index.html`. Make sure:
- Firebase project is properly configured
- Web app is registered in Firebase Console
- Authentication and Firestore are enabled

### Troubleshooting

**Build Fails:**
- Check that Flutter SDK is available in the build environment
- Verify all dependencies in `pubspec.yaml` are valid
- Check build logs in Vercel dashboard

**Routing Issues:**
- The `vercel.json` already includes rewrites for SPA routing
- If you have custom routes, update the rewrites section

**404 Errors:**
- Make sure the output directory is correct: `code_hub/build/web`
- Verify the build command completes successfully

**Performance:**
- The configuration includes caching headers for static assets
- Consider enabling Vercel's Edge Network for better performance

## Post-Deployment

1. **Custom Domain** (Optional):
   - Go to Project Settings → Domains
   - Add your custom domain
   - Follow DNS configuration instructions

2. **Environment Variables**:
   - Add any required environment variables
   - Redeploy after adding variables

3. **Monitoring**:
   - Check Vercel Analytics for performance metrics
   - Monitor build logs for any issues

## Continuous Deployment

Once connected to Git:
- Every push to the main branch triggers a production deployment
- Pull requests get preview deployments automatically
- No manual deployment needed!

## Support

For issues:
- Check Vercel documentation: https://vercel.com/docs
- Flutter web documentation: https://docs.flutter.dev/deployment/web
- Check build logs in Vercel dashboard

