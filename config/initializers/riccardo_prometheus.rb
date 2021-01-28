#https://samsaffron.com/archive/2018/02/02/instrumenting-rails-with-prometheus

# in config/initializers/prometheus.rb

# if Rails.env != "test"
#     require 'prometheus_exporter/middleware'

#     # This reports stats per request like HTTP status and timings
#     Rails.application.middleware.unshift PrometheusExporter::Middleware
# end