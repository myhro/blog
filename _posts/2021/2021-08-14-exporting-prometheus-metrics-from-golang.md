---
date: 2021-08-14
layout: post
title: Exporting Prometheus metrics from Go
...

Exporting [Prometheus][prometheus] metrics is quite straightforward, specially from a Go application - it is a Go project after all, as long as you know the basics of the process. The first step is to understand that Prometheus is not just a monitoring system, but also a time series database. So in order to collect metrics with it, there are three components involved: an application exporting its metrics in Prometheus format, a Prometheus scraper that will grab these metrics in pre-defined intervals and a time series database that will store them for later consumption - usually Prometheus itself, but it's possible to use [other storage backends][storage-backends]. The focus here is the first component, the metrics export process.

The first step is to decide which type is more suitable for the metric to be exported. The Prometheus documentation gives [a nice explanation about the four types (Counter, Gauge, Histogram and Summary) offered][metric-types]. What's important to understand is that they are basically a metric name (like `job_queue_size`), possibly associated with labels (like `{type="email"}`) that will have a numeric value associated with it (like `10`). When scraped, these will be associated with the collection time, which makes it possible, for instance, to later plot these values in a graph. Different types of metrics will offer different facilities to collect the data.

Next, there's a need to decide when metrics will be observed. The short answer is "[synchronously, at collection time][scheduling]". The application shouldn't worry about observing metrics in the background and give the last collected values when scraped. The scrape request itself should trigger the metrics observation - it doesn't matter if this process isn't instant. The long answer is that it depends, as when monitoring events, like HTTP requests or jobs processed in a queue, metrics will be observed at event time to be later collected when scraped.

The following example will illustrate how metrics can be observed at event time:

```go
package main

import (
  "io"
  "log"
  "net/http"

  "github.com/gorilla/mux"
  "github.com/prometheus/client_golang/prometheus"
  "github.com/prometheus/client_golang/prometheus/promhttp"
)

var httpRequestsTotal = prometheus.NewCounter(
  prometheus.CounterOpts{
    Name:        "http_requests_total",
    Help:        "Total number of HTTP requests",
    ConstLabels: prometheus.Labels{"server": "api"},
  },
)

func HealthCheck(w http.ResponseWriter, r *http.Request) {
  httpRequestsTotal.Inc()
  w.WriteHeader(http.StatusOK)
  io.WriteString(w, "OK")
}

func main() {
  prometheus.MustRegister(httpRequestsTotal)

  r := mux.NewRouter()
  r.HandleFunc("/healthcheck", HealthCheck)
  r.Handle("/metrics", promhttp.Handler())

  addr := ":8080"
  srv := &http.Server{
    Addr:    addr,
    Handler: r,
  }
  log.Print("Starting server at ", addr)
  log.Fatal(srv.ListenAndServe())
}
```

There's a single Counter metric called `http_requests_total` (the "total" suffix is a [naming convention][metric-naming]) with a constant label `{server="api"}`. The `HealthCheck()` HTTP handler itself will call the `Inc()` method responsible for incrementing this counter, but in a real-life application that would [preferable be done in a HTTP middleware][middleware]. It's important to not forget to register the metrics variable within the `prometheus` library itself, otherwise it won't show up in the collection.

Let's see how they work using the [`xh` HTTPie Rust clone][xh]:

```
$ xh localhost:8080/metrics | grep http_requests_total
# HELP http_requests_total Total number of HTTP requests
# TYPE http_requests_total counter
http_requests_total{server="api"} 0
```
```
$ xh localhost:8080/healthcheck
HTTP/1.1 200 OK
content-length: 2
content-type: text/plain; charset=utf-8
date: Sat, 14 Aug 2021 12:26:03 GMT

OK
```
```
$ xh localhost:8080/metrics | grep http_requests_total
# HELP http_requests_total Total number of HTTP requests
# TYPE http_requests_total counter
http_requests_total{server="api"} 1
```

This is cool, but as the metric relies on constant labels, the measurement isn't that granular. With a small modification we can use dynamic labels to store this counter per route and HTTP method:

```diff
diff --git a/main.go b/main.go
index 5d6079a..53249b1 100644
--- a/main.go
+++ b/main.go
@@ -10,16 +10,17 @@ import (
        "github.com/prometheus/client_golang/prometheus/promhttp"
 )

-var httpRequestsTotal = prometheus.NewCounter(
+var httpRequestsTotal = prometheus.NewCounterVec(
        prometheus.CounterOpts{
                Name:        "http_requests_total",
                Help:        "Total number of HTTP requests",
                ConstLabels: prometheus.Labels{"server": "api"},
        },
+       []string{"route", "method"},
 )

 func HealthCheck(w http.ResponseWriter, r *http.Request) {
-       httpRequestsTotal.Inc()
+       httpRequestsTotal.WithLabelValues("/healthcheck", r.Method).Inc()
        w.WriteHeader(http.StatusOK)
        io.WriteString(w, "OK")
 }
```

Again, in a real-life application it's better to [let the route be auto-discovered in runtime][current-route] instead of hard-coding its value within the handler. The result will look like:


```
$ xh localhost:8080/metrics | grep http_requests_total
# HELP http_requests_total Total number of HTTP requests
# TYPE http_requests_total counter
http_requests_total{route="/healthcheck",method="GET",server="api"} 1
```

The key here is to understand that the counter vector doesn't that mean multiple values will be stored in the same metric. What it does is to use different label values to create a multi-dimensional metric, where each label combination is an element of the vector.


[current-route]: https://pkg.go.dev/github.com/gorilla/mux#CurrentRoute
[metric-naming]: https://prometheus.io/docs/practices/naming/
[metric-types]: https://prometheus.io/docs/concepts/metric_types/
[middleware]: https://github.com/gorilla/mux#middleware
[prometheus]: https://prometheus.io/
[scheduling]: https://prometheus.io/docs/instrumenting/writing_exporters/#scheduling
[storage-backends]: https://prometheus.io/docs/operating/integrations/#remote-endpoints-and-storage
[xh]: https://github.com/ducaale/xh
