#!/bin/sh

###
 #   Includes
### ###########

. $(ctx download-resource "components/utils")
CONFIG_REL_PATH="components/rabbitmq/config"

### 
### Exports
### #########


export RABBITMQ_SOURCE_URL=$(ctx node properties source_url)
export ERLANG_SOURCE_URL=$(ctx node properties erlang_source_url)
export RABBITMQ_LOG_PATH="/var/log/rabbitmq"

   
export RABBITMQ_USERNAME="$(ctx node properties rabbitmq_username)"
export RABBITMQ_PASSWORD="$(ctx node properties rabbitmq_password)"


# 
#    Log
### ############

ctx logger info "Installing RabbitMQ..."
ctx logger info "User ${RABBITMQ_USERNAME} "
ctx logger info "Log Path ${RABBITMQ_LOG_PATH} "

###
 #   Installation
### ###############

set_selinux_permissive
create_dir "${RABBITMQ_LOG_PATH}"

yum_install ${ERLANG_SOURCE_URL}
yum_install ${RABBITMQ_SOURCE_URL}


deploy_logrotate_config "rabbitmq"

# Creating rabbitmq systemd stop script
deploy_blueprint_resource "${CONFIG_REL_PATH}/kill-rabbit" "/usr/local/bin/kill-rabbit"
sudo chmod 500 /usr/local/bin/kill-rabbit

configure_systemd_service "rabbitmq"


ctx logger info "Configuring File Descriptors Limit..."
deploy_blueprint_resource "${CONFIG_REL_PATH}/rabbitmq_ulimit.conf" "/etc/security/limits.d/rabbitmq.conf"

sudo systemctl daemon-reload

ctx logger info "Chowning RabbitMQ logs path..."
sudo chown rabbitmq:rabbitmq ${RABBITMQ_LOG_PATH}

ctx logger info "Starting RabbitMQ Server in Daemonized mode..."

sudo systemctl start rabbitmq.service

# Wait for rabbit mq to startup
run_command_with_retries "sudo rabbitmqctl status"

### 
##   RAbbitMQ Configuration
# # #########################


ctx logger info "Enabling RabbitMQ Plugins..."
# Occasional timing issues with rabbitmq starting have resulted in failures when first trying to enable plugins
run_command_with_retries "sudo rabbitmq-plugins enable rabbitmq_management"
run_command_with_retries "sudo rabbitmq-plugins enable rabbitmq_tracing"



ctx logger info "Creating new RabbitMQ user and setting permissions and administrator TAG"
run_command_with_retries sudo rabbitmqctl add_user ${RABBITMQ_USERNAME} ${RABBITMQ_PASSWORD}
run_noglob_command_with_retries sudo rabbitmqctl set_permissions ${RABBITMQ_USERNAME} '.*' '.*' '.*'
run_noglob_command_with_retries sudo rabbitmqctl set_user_tags rabbitmq 'administrator'


BROKER_IP=$(ctx instance host_ip)
ctx logger info "RabbitMQ Endpoint IP is: ${BROKER_IP}"
ctx instance runtime_properties rabbitmq_endpoint_ip ${BROKER_IP}