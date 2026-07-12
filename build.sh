#!/bin/sh
# Builds the site into _site/: copies static files, converts posts/*.md to HTML
# with pandoc, and generates the posts index page.
set -eu

out="_site"
rm -rf "$out"
mkdir -p "$out/posts"

cp index.html profile_pic.jpg CNAME "$out/"

entries=""
for f in posts/*.md; do
  slug=$(basename "$f" .md)
  title=$(sed -n 's/^title: *//p' "$f" | head -1)
  date=$(sed -n 's/^date: *//p' "$f" | head -1)
  pandoc "$f" -o "$out/posts/$slug.html" --template=post-template.html
  entries="$entries$date|$slug|$title
"
done

{
  cat <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Posts</title>
  <style>
    body {
      margin: 1em auto;
      max-width: 42em;
      padding: 0 1em;
    }
  </style>
</head>
<body>
  <p><a href="/">&larr; home</a></p>

  <ul>
EOF
  printf '%s' "$entries" | sort -r | while IFS='|' read -r date slug title; do
    [ -n "$slug" ] || continue
    printf '    <li><a href="%s.html">%s</a> - %s</li>\n' "$slug" "$title" "$date"
  done
  cat <<'EOF'
  </ul>
</body>
</html>
EOF
} > "$out/posts/index.html"

echo "Built $(ls "$out"/posts/*.html | wc -l | tr -d ' ') pages into $out/"
