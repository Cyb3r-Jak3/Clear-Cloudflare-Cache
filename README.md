# 🧹 Clear Cloudflare Cache 🧹
---

A Github Action that clears cache from Cloudflare.

**It is recommended to use API Token over Global API Key and all senstive information like zones and tokens should be stored with [encrypted secrets](https://docs.github.com/en/free-pro-team@latest/actions/reference/encrypted-secrets)**





### Example workflow


```yaml

name: Deploy Site
on: push

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:

    # Put steps here to build your site, check, and deploy your site.

    - name: Clear Cloudflare cache
      uses: Cyb3r-Jak3/clear-cloudflare-cache@0.0.1
      env:
        # Zone is required by both methods
        zone: ${{ secrets.CLOUDFLARE_ZONE }}

        # Using API Token
        api_token: ${{ secrets.CLOUDFLARE_TOKEN }}

        # Using Global Token
        email: ${{ secrets.CLOUDFLARE_EMAIL }}
        global_token: ${{ secrets.CLOUDFLARE_KEY }}
```