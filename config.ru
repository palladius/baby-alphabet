# This file is used by Rack-based servers to start the application.

require_relative "config/environment"

# BEGIN aggiunto da prometheus
require 'prometheus/middleware/collector'
require 'prometheus/middleware/exporter'
use Prometheus::Middleware::Collector
use Prometheus::Middleware::Exporter
# END prometheus

run Rails.application
Rails.application.load_server
