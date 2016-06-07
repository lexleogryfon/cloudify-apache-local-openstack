#!/bin/bash -e

INSTALL_RIEMANN_DASH=$(ctx node properties install_rieman_dash)

ctx logger info "Stop Script - Stopping Riemann..."
sudo systemctl stop riemann.service

if [[ "${INSTALL_RIEMANN_DASH}" = "True" ]]; then
	ctx logger info "Start script - Starting Riemann dash "
	sudo systemctl stop riemann-dash.service
fi