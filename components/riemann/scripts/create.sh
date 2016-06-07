#!/bin/sh

. $(ctx download-resource "components/utils")

CONFIG_REL_PATH="components/riemann/config"
DASH_CONFIG_REL_PATH="components/riemann-dash/config"


ctx logger info "Create Script - Installing Riemann..."

export LANGOHR_SOURCE_URL=$(ctx node properties langohr_jar_source_url)
export DAEMONIZE_SOURCE_URL=$(ctx node properties daemonize_rpm_source_url)
export RIEMANN_SOURCE_URL=$(ctx node properties riemann_rpm_source_url)

export RIEMANN_CONFIG_PATH="/etc/riemann"
export RIEMANN_LOG_PATH="/var/log/riemann"
export LANGOHR_HOME="/opt/lib"
export EXTRA_CLASSPATH="${LANGOHR_HOME}/langohr.jar"

export RABBITMQ_USERNAME="$(ctx node properties rabbitmq_username)"
export RABBITMQ_PASSWORD="$(ctx node properties rabbitmq_password)"

INSTALL_RIEMANN_DASH=$(ctx node properties install_rieman_dash)

# Confirm username and password have been supplied for broker before continuing
# Components other than logstash and riemann have this handled in code already
# Note that these are not directly used in this script, but are used by the deployed resources, hence the check here.
if [[ -z "${RABBITMQ_USERNAME}" ]] ||
   [[ -z "${RABBITMQ_PASSWORD}" ]]; then
  sys_error "Both rabbitmq_username and rabbitmq_password must be supplied and at least 1 character long in the manager blueprint inputs."
fi

#ctx instance runtime_properties rabbitmq_endpoint_ip "$(get_rabbitmq_endpoint_ip)"


set_selinux_permissive

copy_notice "riemann"
create_dir ${RIEMANN_LOG_PATH}
create_dir ${LANGOHR_HOME}
create_dir ${RIEMANN_CONFIG_PATH}
create_dir ${RIEMANN_CONFIG_PATH}/conf.d

langohr=$(download_cloudify_resource ${LANGOHR_SOURCE_URL})
sudo cp ${langohr} ${EXTRA_CLASSPATH}
ctx logger info "Applying Langohr permissions..."
sudo chmod 644 ${EXTRA_CLASSPATH}
ctx logger info "Installing Daemonize..."
yum_install ${DAEMONIZE_SOURCE_URL}
yum_install ${RIEMANN_SOURCE_URL}

deploy_logrotate_config "riemann"

# Deplot rabbitmq main file

ctx logger info "Deploying Riemann conf..."
deploy_blueprint_resource "${CONFIG_REL_PATH}/riemann.config" "${RIEMANN_CONFIG_PATH}/riemann.config"

deploy_blueprint_resource "${CONFIG_REL_PATH}/rabbitmq.clj" "${RIEMANN_CONFIG_PATH}/conf.d/rabbitmq.clj"


# our riemann configuration will (by default) try to read these environment variables. If they don't exist, it will assume
# that they're found at "localhost"
# export MANAGEMENT_IP=""
# export RABBITMQ_HOST=""

# we inject the management_ip for both of these to Riemann's systemd config. These should be potentially different
# if the manager and rabbitmq are running on different hosts.
configure_systemd_service "riemann"

###
##  Install dash board 
##  TODO if input
################

ctx logger info "Installig riemann dash Section."

echo "install rieman dash is " ${INSTALL_RIEMANN_DASH}

if [[ "${INSTALL_RIEMANN_DASH}" = "True" ]]; then
  
    ctx logger info "Installig ruby for riemann-dash..."
    yum_install rubygems.noarch

    ctx logger info "Installing riemann-dash gems"
    sudo gem install riemann-client riemann-tools riemann-dash

    deploy_blueprint_resource "${DASH_CONFIG_REL_PATH}/dash.config" "${RIEMANN_CONFIG_PATH}/dash.config"

    configure_systemd_service "riemann-dash"
fi



clean_var_log_dir riemann