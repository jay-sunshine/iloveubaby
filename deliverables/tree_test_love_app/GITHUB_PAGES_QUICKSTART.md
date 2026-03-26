# GitHub Pages Quickstart

## Repo
- GitHub repo: `https://github.com/jay-sunshine/iloveubaby`
- Expected Pages URL: `https://jay-sunshine.github.io/iloveubaby/`

## 1) Add GitHub remote
```powershell
git -C "E:\山河志风起汉末" remote add github https://github.com/jay-sunshine/iloveubaby.git
```

If `github` already exists:
```powershell
git -C "E:\山河志风起汉末" remote set-url github https://github.com/jay-sunshine/iloveubaby.git
```

## 2) Push current branch
```powershell
git -C "E:\山河志风起汉末" push -u github master
```

## 3) Enable Pages by API
Set a PAT into env first, then run the helper script:
```powershell
$env:GITHUB_TOKEN = "YOUR_PAT"
powershell -ExecutionPolicy Bypass -File "E:\山河志风起汉末\tools\export\enable_github_pages.ps1"
```

## 4) Trigger the workflow again if needed
```powershell
git -C "E:\山河志风起汉末" commit --allow-empty -m "trigger pages build"
git -C "E:\山河志风起汉末" push github master
```

## Notes
- The workflow file is `E:\山河志风起汉末\.github\workflows\love_web_pages.yml`.
- It exports only the isolated love scene on CI.
- First deployment may take several minutes.

