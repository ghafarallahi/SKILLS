---
name: perf-baseline
description: Measure the performance of a web page in a real browser, save a baseline, and compare each later run against it with relative thresholds. Use for "how fast is the page", "performance regression", "bundle size", "page weight", before a marketing page ships, and after a change to a page's build.
---

# Performance baseline

A performance claim needs a measurement. A measurement needs a baseline to compare
against. This skill produces both. It reports raw values; it never produces a composite
score, because an invented number is not a measurement.

## 1. Measure inside the page

Open the page in a real browser. Run the collection script inside the page, not outside:

- `performance.getEntriesByType("navigation")[0]` gives the load timings.
- `performance.getEntriesByType("paint")` gives first paint and first contentful paint.
- `performance.getEntriesByType("resource")` gives each resource with its
  `transferSize`.

Serialize inside the page with `JSON.stringify(entry.toJSON())`. The fields of a
PerformanceEntry are getters. A copy made outside the page loses them.

## 2. Take the median of three, under fixed conditions

Load the page three times with the cache disabled (a hard reload), and collect after
each load. A cached resource reports `transferSize` 0, and a zero hides growth. When
`transferSize` is 0 and `decodedBodySize` is not, use `decodedBodySize`, and record
which field the measurement used. A cross-origin resource without a
`Timing-Allow-Origin` header hides both fields: count those resources separately, and
when a script's bytes are hidden, the bundle metric is a failed measurement, not a zero.

Fix the collection conditions, and use the same conditions every run:

- Collect after the `load` event plus a fixed quiet delay of two seconds, so late
  resources are in the sample.
- Set `performance.setResourceTimingBufferSize(1000)` before the page loads resources.
  When the resource count equals the buffer size, entries were dropped: report it, and
  do not compare that run.
- When a required metric is absent (no `first-contentful-paint` entry), record it as
  absent. An absent required metric is a failed measurement, not a pass.

A single run varies with the network. The median of three removes the worst of the
variance. Record these medians: `domContentLoadedEventEnd`, `loadEventEnd`,
`first-contentful-paint`, the total transferred bytes, the resource count, and the
transferred script bytes — the bundle. When the project has build output, read the
bundle bytes from the build instead: the build number is fully deterministic. The page
measurement is the fallback.

## 3. Save the baseline, and do not edit it

Write the medians to `perf-baseline.json` in the project: the page URL, the date, the
commit, the machine, the collection settings (cache mode, quiet delay, byte field), and
each metric. Do not edit a baseline. When you accept a new level, write a new file with
the date in its name and keep the old file. The newest dated file is the active
baseline.

## 4. Compare with relative thresholds

A later run regresses when one of these is true:

- A timing metric grows more than 50 percent over the baseline, and more than 500
  milliseconds.
- The bundle bytes grow more than 25 percent.

Report each regression with the metric, the baseline value, and the new value. A page
that passes is one line.

## 5. The limits of this skill

- The numbers come from one machine and one network. Compare runs from the same
  machine. A laptop baseline does not judge a CI run.
- A local measurement is not field data. When the product has real-user monitoring,
  use that data instead.
- This skill measures web pages. A native application needs the profiler of its
  platform.
