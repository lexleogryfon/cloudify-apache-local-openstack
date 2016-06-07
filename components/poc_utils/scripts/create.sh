#!/bin/sh
#
# this script will install utils and libraries

. $(ctx download-resource "components/utils")

CONTENT_REL_PATH="components/poc_utils/content"

CONFIG_REL_PATH="components/poc_utils/config"


RIEMANN_CONFIG_PATH="/etc/riemann"

POC_UTILS_PATH="/root/qalyzer/poc-utils"

ctx logger info "Installing Poc Utils..."


###
#      Setup Env.
###  ###############

set_selinux_permissive

ctx logger info "Installing epel-release for the python pika library..."

yum_install epel-release

ctx logger info "Installing pika python library..."

yum_install  python2-pika

##
# #   Deploy POC utils
##   ####################

ctx logger info "Deploying poc utils scripts..."

create_dir "${POC_UTILS_PATH}"

deploy_blueprint_resource "${CONTENT_REL_PATH}/qalyzer_publish.py" "${POC_UTILS_PATH}/qalyzer_publish.py"
deploy_blueprint_resource "${CONTENT_REL_PATH}/qalyzer_auto_publish.py" "${POC_UTILS_PATH}/qalyzer_auto_publish.py"

# addexecute permissions
sudo chmod +x "${POC_UTILS_PATH}/qalyzer_auto_publish.py"
sudo chmod +x "${POC_UTILS_PATH}/qalyzer_publish.py"


ctx logger info "Deploying riemman POC poc.clj configuration..."

deploy_blueprint_resource "${CONFIG_REL_PATH}/poc.clj" "${RIEMANN_CONFIG_PATH}/conf.d/poc.clj"

sudo systemctl restart riemann