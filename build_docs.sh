#!/bin/bash

appledoc --no-repeat-first-par --no-create-docset --create-html --project-name "OCD3" --project-company "Tilde Inc" --company-id io.tilde --output docs .
ditto docs /tmp/ocd3docs/
git checkout gh-pages
ditto /tmp/ocd3docs docs
git add docs
git commit -m "Update docs"
git push origin gh-pages
git checkout master