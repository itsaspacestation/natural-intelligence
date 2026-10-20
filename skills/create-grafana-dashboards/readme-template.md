# Dashboard README template

Back to [`create-grafana-dashboards`](SKILL.md). Copy the block, keep the section order, drop a
section only when the dashboard has no such row. Angle brackets mark what to fill in.
No vendor figures: quotas, defaults, class sizes, and prices change, so each section
links the page that holds them.

```markdown
# <Vendor> <Service>

Reference: <official monitoring page URL>

Quotas: <service quotas page URL>

<One sentence: namespaces or metric families used, method applied (RED, then
saturation and limits), log source, optional rows.>

<One sentence naming the metric families left out and why: other engine, serverless
only, feature not deployed.>

![Header](./0_Header.png)

## Deployed variant
<The infrastructure as code the dashboard was built against: module, engine, class
family, provisioned or serverless, replicas, log exports, monitoring switches. Name
the module defaults that could not be read.>

## <Row 1 title, as on the dashboard>
<Dimensions used and why. One sentence on what the row answers.>

- Rate: <panels>
- Errors: <panels>
- Duration: <panels>

<Limits drawn on this row and where their value comes from: variable, quota math,
threshold line. Sentinel values the vendor documents.>

Reference: <section anchor on the monitoring page, or the page that documents the limit>

![<Row 1 title>](./1_<Row_1>.png)

## <Row 2 title>
<Same shape. A long row carries two images: _1 and _2.>

![<Row 2 title>](./2_<Row_2>_1.png)
![<Row 2 title>](./2_<Row_2>_2.png)

## Logs
<Log source, log group pattern with the resource name as a placeholder, filter
variable, what it costs.>

Reference: <log export page URL>

![Logs](./<n>_Logs.png)

## Usage metrics and quotas
<Usage namespace, quota math, warning line. One table: quota name and its console
link, no default values.>

| Quota | Console |
|---|---|
| <name> | <console URL with the quota code> |

Reference: <usage metrics page URL>

![Usage metrics and quotas](./<n>_Usage.png)

## <Paid or opt-in source> (optional)
Collapsed. <Metrics it adds, when they are published, free tier and what is charged,
in words.>

Reference: <its own page URL>

Pricing: <vendor pricing page URL>

![<Paid source>](./<n>_<Source>.png)

## Setup
<Only when the source needs instrumentation packages or an agent: the commands, one
per line, following the shell rules.>
```

Rules the template encodes:

- The reference line comes first and its URL is the one in the dashboard links array.
- One heading per row, in dashboard order, each with its image once the human has
  supplied it. No image line before the file exists.
- A row that draws a limit says where the value comes from and links the page that
  documents it; the number itself stays out.
- Optional rows say "optional", "collapsed", and what they cost, and link their own
  reference page.
- The grafana.com link is added after the first publish, in the links array and as a
  line under the title.
