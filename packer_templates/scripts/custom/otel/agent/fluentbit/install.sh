#!/usr/bin/env bash

OS_ARCH=${OS_ARCH:-"x86_64"}
OS_NAME=${OS_NAME:-"ubuntu"}
OS_VERSION=${OS_VERSION:-"20.04"}


FLUENT_CONF_DIR=${FLUENT_CONF_DIR:-"/etc/fluent-bit"}

# TODO:
# 1. 监听kubelet/docker/containerd日志
# 2. 监听kubernetes组件的日志
# 3. 监听dmesg的日志
# 4. 监听syslog的日志


function generate_input_conf(){
    cat > ${FLUENT_CONF_DIR}/input_systemd.conf << EOF
[INPUT]
    Name              systemd
    Tag               systemd.**
    Path              /var/log/journal
    Systemd_Filter    _SYSTEMD_UNIT=containerd.service
    Systemd_Filter    _SYSTEMD_UNIT=docker.service
    Systemd_Filter    _SYSTEMD_UNIT=kubelet.service
    DB                /var/log/flb_kube.db 
    Mem_Buf_Limit    5MB
EOF

    cat > ${FLUENT_CONF_DIR}/input_otel.conf << EOF
[INPUT]
    name            opentelemetry
    tag             otel
    listen          127.0.0.1
    port            4318
EOF

    cat > ${FLUENT_CONF_DIR}/input_var_logs_file.conf << EOF
[INPUT]
    Name            tail
    Tag             varlog.*
    Path            /var/log/syslog,/var/log/kern.log,/var/log/dmesg
    PathKey         filename
    Exclude_Path    *.gz,*.zip
    DB              /var/log/flb_varlog.db
    Mem_Buf_Limit   5MB
    Skip_Long_Lines Off
    Read_from_Head  True
EOF

cat > ${FLUENT_CONF_DIR}/input_dmesg.conf << EOF
[INPUT] 
    Name        kmsg
    Tag         kernel
    Prio_Level   8  
EOF

    cat > ${FLUENT_CONF_DIR}/input_containers_logs.conf << EOF
[INPUT]
    Name            tail
    Tag             kube.containers.*
    Path            /var/log/containers/*.log
    PathKey         filename
    Exclude_Path    *.gz,*.zip
    DB              /var/log/flb_containerlog.db
    Mem_Buf_Limit   5MB
    Skip_Long_Lines Off
    multiline.parser docker, cri
    Read_from_Head true
    
EOF

    cat > ${FLUENT_CONF_DIR}/input_cni_logs.conf << EOF
[INPUT]
    Name            tail
    Tag             cni.*
    Path            /var/log/*/cni/*.log
    PathKey         filename
    Exclude_Path    *.gz,*.zip
    DB              /var/log/flb_cni.db
    Mem_Buf_Limit   5MB
    Skip_Long_Lines Off
    Read_from_Head true
EOF

    cat > ${FLUENT_CONF_DIR}/input_metrics.conf << EOF
[INPUT]
    name            fluentbit_metrics
    tag             fluentbit_metrics
    scrape_interval 2

[INPUT]
    name            node_exporter_metrics
    tag             node_metrics
    scrape_interval 2

[INPUT]
    name                    process_exporter_metrics
    tag                     process_metrics
    scrape_interval         2
    path.procfs             /proc
    process_include_pattern .+
    process_exclude_pattern NULL
    metrics                 cpu,io,memory,state,context_switches,fd,start_time,thread_wchan,thread
EOF
}

function generate_output_conf(){
    cat > ${FLUENT_CONF_DIR}/output_otel.conf << EOF
[OUTPUT]
    Name                 opentelemetry
    Match                *
    Host                 localhost
    Port                 443
    Metrics_uri          /v1/metrics
    Logs_uri             /v1/logs
    Traces_uri           /v1/traces
    Log_response_payload True
    Tls                  On
    Tls.verify           Off
    logs_body_key $message
    logs_span_id_message_key span_id
    logs_trace_id_message_key trace_id
    logs_severity_text_message_key loglevel
    logs_severity_number_message_key lognum
    # add user-defined labels
    add_label            app fluent-bit
    add_label            color blue

EOF

    cat > ${FLUENT_CONF_DIR}/output_stdout.conf << EOF
[OUTPUT]
    name  stdout
    match *
EOF
}


function generate_filter_conf(){
    cat > ${FLUENT_CONF_DIR}/filter_append_ip.conf << EOF
[FILTER]
    Name record_modifier
    Match *

    Record hostname ${HOSTNAME}
    Record FluentIP ${Fluent_IP}
    Record FluentID ${Fluent_ID}
EOF
}

function generate_fluent_bit_conf(){
    cat > ${FLUENT_CONF_DIR}/fluent-bit.conf << EOF
    [SERVICE]
    # Flush
    # =====
    # set an interval of seconds before to flush records to a destination
    flush        1

    # Daemon
    # ======
    # instruct Fluent Bit to run in foreground or background mode.
    daemon       Off

    # Log_Level
    # =========
    # Set the verbosity level of the service, values can be:
    #
    # - error
    # - warning
    # - info
    # - debug
    # - trace
    #
    # by default 'info' is set, that means it includes 'error' and 'warning'.
    log_level    info

    # Parsers File
    # ============
    # specify an optional 'Parsers' configuration file
    parsers_file parsers.conf

    # Plugins File
    # ============
    # specify an optional 'Plugins' configuration file to load external plugins.
    plugins_file plugins.conf

    # HTTP Server
    # ===========
    # Enable/Disable the built-in HTTP Server for metrics
    http_server  Off
    http_listen  0.0.0.0
    http_port    2020

    # Storage
    # =======
    # Fluent Bit can use memory and filesystem buffering based mechanisms
    #
    # - https://docs.fluentbit.io/manual/administration/buffering-and-storage
    #
    # storage metrics
    # ---------------
    # publish storage pipeline metrics in '/api/v1/storage'. The metrics are
    # exported only if the 'http_server' option is enabled.
    #
    storage.metrics on

    # storage.path
    # ------------
    # absolute file system path to store filesystem data buffers (chunks).
    #
    # storage.path /tmp/storage

    # storage.sync
    # ------------
    # configure the synchronization mode used to store the data into the
    # filesystem. It can take the values normal or full.
    #
    # storage.sync normal

    # storage.checksum
    # ----------------
    # enable the data integrity check when writing and reading data from the
    # filesystem. The storage layer uses the CRC32 algorithm.
    #
    # storage.checksum off

    # storage.backlog.mem_limit
    # -------------------------
    # if storage.path is set, Fluent Bit will look for data chunks that were
    # not delivered and are still in the storage layer, these are called
    # backlog data. This option configure a hint of maximum value of memory
    # to use when processing these records.
    #
    # storage.backlog.mem_limit 5M


    @INCLUDE input_*.conf
    @INCLUDE filter_*.conf
    @INCLUDE output.conf
EOF
}

function generate_conf() {
    generate_fluent_bit_conf
    generate_input_conf
    generate_filter_conf
    generate_output_conf                                                                                                                                                                                                                                                                                                                                                         
}

function install_tools_ubuntu() {
    case "${OS_VERSION}" in
    20.04)
        curl https://packages.fluentbit.io/fluentbit.key | gpg --dearmor > /usr/share/keyrings/fluentbit-keyring.gpg
        echo \
        "deb [signed-by=/usr/share/keyrings/fluentbit-keyring.gpg] https://packages.fluentbit.io/ubuntu/$(lsb_release -cs) $(lsb_release -cs) main" \
        | sudo tee /etc/apt/sources.list.d/fluentbit.list > /dev/null
        sudo apt update -y
        sudo apt-get install fluent-bit -y

        # https://docs.fluentbit.io/manual/administration/configuring-fluent-bit/classic-mode/variables
        # 追加一些变量到默认fluent-bit默认环境变量文件中, 后续可以在fluent-bit可以通过${var}的方式来使用
        # 通过record_modifier将信息追加到fluent-bit的每条日志项中
        # 
        # 当前fluent运行实例IP
        echo Fluent_IP=`hostname -I | awk '{ print $1 }'` >> /etc/default/fluentbit
        # 生成唯一的UUID, 避免IP漂移
        echo Fluent_ID=`uuidgen` >> /etc/default/fluentbit

        sudo systemctl enable fluent-bit
        sudo systemctl start fluent-bit
        ;;
    *)
        echo "not support install in os ${OS_NAME}/${OS_VERSION}, exit installation"
        exit 1
        ;;
    esac
}

case "${OS_NAME}" in
ubuntu)
    install_tools_ubuntu
    ;;
*)
    echo "not support install in os ${OS_NAME}, exit installation"
    exit 1
    ;;
esac
