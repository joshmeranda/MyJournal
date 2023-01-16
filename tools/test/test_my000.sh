#!/usr/bin/env sh

. "$(dirname "$0")/config"

test_image=markdownlint/markdownlint:0.11.0
ruleset="$journal_dir/rulesets.rb"
mdlrc="$journal_dir/.mdlrc"
test_md="$journal_test_resource_dir/test.md"

assertNotContainsLine()
{
  line_no="$1"
  container="$2"
  substr="/test.md:$line_no: MY000"

  assertNotContains "lineno: $line_no" "$container" "$substr"
}

assertContainsLine()
{
  line_no="$1"
  container="$2"
  substr="/test.md:$line_no: MY000"

  assertContains "$container" "$substr"
}

test_rulesets_ignore_all()
{
  out="$(docker run \
    --mount type=bind,source="$ruleset",target=/rulesets.rb \
    --mount type=bind,source="$journal_test_resource_dir/my000-style-ignore-all.rb",target=/style.rb \
    --mount type=bind,source="$mdlrc",target=/.mdlrc \
    --mount type=bind,source="$test_md",target=/test.md \
    "$test_image" --config /.mdlrc --verbose /test.md)"

    assertNotContainsLine 1 "$out"

    assertContainsLine 2 "$out"
    assertContainsLine 3 "$out"

    assertNotContainsLine 4 "$out"
    assertNotContainsLine 5 "$out"

    assertContainsLine 6 "$out"
    assertContainsLine 7 "$out"

    assertNotContainsLine 8 "$out"
    assertNotContainsLine 9 "$out"
    assertNotContainsLine 10 "$out"
    assertNotContainsLine 11 "$out"
    assertNotContainsLine 12 "$out"
    assertNotContainsLine 13 "$out"
    assertNotContainsLine 14 "$out"
    assertNotContainsLine 15 "$out"
    assertNotContainsLine 16 "$out"
    assertNotContainsLine 17 "$out"
}

test_rulesets_limit_code_blocks()
{
  out="$(docker run \
    --mount type=bind,source="$ruleset",target=/rulesets.rb \
    --mount type=bind,source="$journal_test_resource_dir/my000-style-limit-code-blocks.rb",target=/style.rb \
    --mount type=bind,source="$mdlrc",target=/.mdlrc \
    --mount type=bind,source="$test_md",target=/test.md \
    "$test_image" --config /.mdlrc --verbose /test.md)"

    assertNotContainsLine 1 "$out"

    assertContainsLine 2 "$out"
    assertContainsLine 3 "$out"

    assertNotContainsLine 4 "$out"
    assertNotContainsLine 5 "$out"

    assertContainsLine 6 "$out"
    assertContainsLine 7 "$out"

    assertNotContainsLine 8 "$out"
    assertNotContainsLine 9 "$out"
    assertNotContainsLine 10 "$out"
    assertNotContainsLine 11 "$out"
    assertNotContainsLine 12 "$out"
    assertNotContainsLine 13 "$out"

    assertContainsLine 14 "$out"

    assertNotContainsLine 15 "$out"
    assertNotContainsLine 16 "$out"
    assertNotContainsLine 17 "$out"
}

test_rulesets_limit_tables()
{
  out="$(docker run \
    --mount type=bind,source="$ruleset",target=/rulesets.rb \
    --mount type=bind,source="$journal_test_resource_dir/my000-style-limit-tables.rb",target=/style.rb \
    --mount type=bind,source="$mdlrc",target=/.mdlrc \
    --mount type=bind,source="$test_md",target=/test.md \
    "$test_image" --config /.mdlrc --verbose /test.md)"

    assertNotContainsLine 1 "$out"

    assertContainsLine 2 "$out"
    assertContainsLine 3 "$out"

    assertNotContainsLine 4 "$out"
    assertNotContainsLine 5 "$out"

    assertContainsLine 6 "$out"
    assertContainsLine 7 "$out"

    assertNotContainsLine 8 "$out"

    assertContainsLine 9 "$out"
    assertContainsLine 10 "$out"
    assertContainsLine 11 "$out"

    assertNotContainsLine 12 "$out"
    assertNotContainsLine 13 "$out"
    assertNotContainsLine 14 "$out"
    assertNotContainsLine 15 "$out"
    assertNotContainsLine 16 "$out"
    assertNotContainsLine 17 "$out"
}

test_rulesets_limit_links()
{
  out="$(docker run \
    --mount type=bind,source="$ruleset",target=/rulesets.rb \
    --mount type=bind,source="$journal_test_resource_dir/my000-style-limit-links.rb",target=/style.rb \
    --mount type=bind,source="$mdlrc",target=/.mdlrc \
    --mount type=bind,source="$test_md",target=/test.md \
    "$test_image" --config /.mdlrc --verbose /test.md)"

    assertNotContainsLine 1 "$out"

    assertContainsLine 2 "$out"
    assertContainsLine 3 "$out"
    assertContainsLine 4 "$out"
    assertContainsLine 5 "$out"
    assertContainsLine 6 "$out"
    assertContainsLine 7 "$out"

    assertNotContainsLine 8 "$out"
    assertNotContainsLine 9 "$out"
    assertNotContainsLine 10 "$out"
    assertNotContainsLine 11 "$out"
    assertNotContainsLine 12 "$out"
    assertNotContainsLine 13 "$out"
    assertNotContainsLine 14 "$out"
    assertNotContainsLine 15 "$out"
    assertNotContainsLine 16 "$out"

    assertContainsLine 17 "$out"
}

test_rulesets_limit_no_ignore_link_punctuation()
{
  out="$(docker run \
    --mount type=bind,source="$ruleset",target=/rulesets.rb \
    --mount type=bind,source="$journal_test_resource_dir/my000-style-limit-link-punctuation.rb",target=/style.rb \
    --mount type=bind,source="$mdlrc",target=/.mdlrc \
    --mount type=bind,source="$test_md",target=/test.md \
    "$test_image" --config /.mdlrc --verbose /test.md)"

    assertNotContainsLine 1 "$out"
    assertContainsLine 2 "$out"
    assertContainsLine 3 "$out"

    assertNotContainsLine 4 "$out"
    assertNotContainsLine 5 "$out"

    assertContainsLine 6 "$out"
    assertContainsLine 7 "$out"

    assertNotContainsLine 8 "$out"
    assertNotContainsLine 9 "$out"
    assertNotContainsLine 10 "$out"
    assertNotContainsLine 11 "$out"
    assertNotContainsLine 12 "$out"
    assertNotContainsLine 13 "$out"
    assertNotContainsLine 14 "$out"
    assertNotContainsLine 15 "$out"
    assertNotContainsLine 16 "$out"

    assertContainsLine 17 "$out"
}
