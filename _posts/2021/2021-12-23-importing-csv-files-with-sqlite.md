---
date: 2021-12-23
layout: post
title: Importing CSV files with SQLite
...

GitHub offers a very superficial view of how GitHub Actions runners are spending their minutes on private repositories. Currently, the only way to get detailed information about it is via the `Get usage report` button in the [project/organization billing page][billing]. The only problem is that the generated report is a CSV file, shifting the responsibility of filtering and visualizing data to the user. While it's true that most of the users of this report are used to deal with CSV files, be them developers or accountants experts in handling spreadsheets, this is definitely not the most user-friendly way of offering insights into billing data.

When facing this issue, at first I thought about using [harelba/q][q] to query the CSV files directly in the command line. The problem is that `q` isn't that straightforward to install, as apparently it is not available via `apt` nor `pip`, nor one is able to easily change the data once it's imported, like in a regular database. In the first time I resorted to create a database on PostgreSQL and import the CSV file into it, but after that I never remember the CSV import syntax and it still requires a daemon running just for that. I kept thinking that there should be a simpler way: what if I use SQLite for that?

In order to not have to `CAST()` each `TEXT` column whenever working with dates or numbers, the following `schema.sql` can be used:

```sql
CREATE TABLE billing (
  date DATE,
  product TEXT,
  repository TEXT,
  quantity NUMERIC,
  unity TEXT,
  price NUMERIC,
  workflow TEXT,
  notes TEXT
);
```

After that, it's possible to import the CSV file with the `sqlite3` CLI tool. The `--skip 1` argument to the `.import` command [is needed to avoid importing the CSV header as data][import], given that SQLite considers it to be a regular row when the table already exists:

```
$ sqlite3 github.db
SQLite version 3.36.0 2021-06-18 18:58:49
Enter ".help" for usage hints.
sqlite> .read schema.sql
sqlite> .mode csv
sqlite> .import --skip 1 c2860a05_2021-12-23_01.csv billing
sqlite> SELECT COUNT(*) FROM billing;
1834
```

Now it's easy to dig into the billing data. In order to have a better presentation, `.mode column` can be enabled to both show the column names and align their output. We can, for instance, find out which workflows consumed most minutes in the last week and their respective repositories:

```
sqlite> .mode column
sqlite> SELECT date, repository, workflow, quantity FROM billing WHERE date > date('now', '-7 days') AND product = 'actions' ORDER BY quantity DESC LIMIT 5;
date        repository         workflow                              quantity
----------  -----------------  ------------------------------------  --------
2021-12-21  contoso/api        .github/workflows/main.yml            392
2021-12-18  contoso/terraform  .github/workflows/staging-images.yml  361
2021-12-22  contoso/api        .github/workflows/main.yml            226
2021-12-21  contoso/api        .github/workflows/qa.yml              185
2021-12-20  contoso/api        .github/workflows/main.yml            140
```

Another important example of the data that can be fetched is the cost per repository in the last week, summing the cost of all their workflows. An `UPDATE` statement is required to apply a small data fix, given that the CSV contains a dollar sign `$` in the rows of the `price` column that needs to be dropped:

```
sqlite> UPDATE billing SET price = REPLACE(price, '$', '');
sqlite> SELECT repository, SUM(quantity) * price AS amount FROM billing WHERE date > date('now', '-7 days') AND product = 'actions' GROUP BY repository;
repository          amount
------------------  ------
contoso/api         11.68
contoso/public-web  0.128
contoso/status      1.184
contoso/terraform   2.92
contoso/webapp      0.6
```

Not intuitive as a web page where one can just click around to filter and sort a report, but definitely doable. As a side note, one cool aspect of SQLite is that it doesn't require a file database do be used. If started as `sqlite3`, with no arguments, all of it's storage needs are handled entirely in memory. This makes it even more interesting for data exploration cases like these, offering all of its queries capabilities without ever persisting data to disk.

[billing]: https://docs.github.com/en/billing/managing-billing-for-github-actions/viewing-your-github-actions-usage
[import]: https://www.sqlite.org/cli.html#importing_csv_files
[q]: https://harelba.github.io/q/
