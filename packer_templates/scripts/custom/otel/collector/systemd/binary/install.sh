#!/bin/bash
set -ex

OTEL_VERSION=${OTEL_VERSION:-0.103.1}
ARCH=${ARCH:-amd64}
OS=${OS:-linux}

wget https://github.com/open-telemetry/opentelemetry-collector-releases/releases/download/v${OTEL_VERSION}/otelcol-contrib_${OTEL_VERSION}_${OS}_${ARCH}.tar.gz
mkdir /tmp/otelcol-contrib && tar xvzf otelcol-contrib_${OTEL_VERSION}_${OS}_${ARCH}.tar.gz -C /tmp/otelcol-contrib &&  mv /tmp/otelcol-contrib/otelcol-contrib /usr/bin/

cat > /lib/systemd/system/otelcol-contrib.service << EOF
[Unit]
Description=OpenTelemetry Collector Contrib
After=network.target

[Service]
EnvironmentFile=/etc/otelcol-contrib/otelcol-contrib.conf
ExecStart=/usr/bin/otelcol-contrib $OTELCOL_OPTIONS
KillMode=mixed
Restart=on-failure
Type=simple
User=otelcol-contrib
Group=otelcol-contrib

[Install]
WantedBy=multi-user.target
EOF

mkdir -p /etc/otelcol-contrib

cat  > /etc/otelcol-contrib/otelcol-contrib.conf << EOF
# Systemd environment file for the otelcol-contrib service

# Command-line options for the otelcol-contrib service.
# Run `/usr/bin/otelcol-contrib --help` to see all available options.
OTELCOL_OPTIONS="--config=/etc/otelcol-contrib/config.yaml"

EOF


cat > /etc/otelcol-contrib/config.yaml << _EOF_
# 接收器
receivers:
  otlp:
    protocols:
      # 本地监听端口
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318
  # 本地cpu等监控指标      
  hostmetrics:
    collection_interval: 30s
    scrapers:
      cpu: {}
      disk: {}
      load: {}
      filesystem: {}
      memory: {}
      network: {}
      paging: {}
      process:
        mute_process_name_error: true
        mute_process_exe_error: true
        mute_process_io_error: true
      processes: {}
  prometheus:
    config:
      global:
        scrape_interval: 30s
      scrape_configs:
        - job_name: otel-collector-binary
          static_configs:
            - targets: ['localhost:8888']

# 处理器
processors:
  # 批处理
  batch:
    send_batch_size: 1000
    timeout: 10s
  # 内存限制器  
  memory_limiter:
    # Same as --mem-ballast-size-mib CLI argument
    ballast_size_mib: 683
    # 80% of maximum memory up to 2G
    limit_mib: 1500
    # 25% of limit up to 2G
    spike_limit_mib: 512
    check_interval: 5s
  # 排队重试[已废弃]
  # 最大程度减少由于处理延迟或导出数据问题导致丢弃数据。  
  # 
  # queued_retry:
  #   num_workers: 4
  #   queue_size: 100
  #   retry_on_failure: true
  # Ref: https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/main/processor/resourcedetectionprocessor/README.md
  # 资源检测
  resourcedetection:
    detectors: [env, system] # include ec2 for AWS, gcp for GCP and azure for Azure.
    # Using OTEL_RESOURCE_ATTRIBUTES envvar, env detector adds custom labels.
    timeout: 2s
    system:
      hostname_sources: [os] # alternatively, use [dns,os] for setting FQDN as host.name and os as fallback

extensions:
  health_check: {}
  zpages: {}

# 导出器
exporters:
  otlp:
    endpoint: "127.0.0.1:4317" 
    tls:
      insecure: true
  logging:
    # verbosity of the logging export: detailed, normal, basic
    verbosity: detailed

# 服务启用
service:
  telemetry:
    metrics:
      address: 0.0.0.0:8888
  extensions: [health_check, zpages]    
  pipelines:
    metrics:
      receivers: [otlp]
      processors: [batch]
      exporters: [otlp]
    metrics/internal:
      receivers: [prometheus, hostmetrics]
      processors: [resourcedetection, batch]
      exporters: [otlp]
    traces:
      receivers: [otlp]
      processors: [batch]
      exporters: [otlp]
    logs:
      receivers: [otlp]
      processors: [batch]
      exporters: [otlp]
_EOF_