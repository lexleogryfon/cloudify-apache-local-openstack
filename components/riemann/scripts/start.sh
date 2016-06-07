#!/bin/bash -e

INSTALL_RIEMANN_DASH=$(ctx node properties install_rieman_dash)

ctx logger info "Start Script - Starting Riemann..."
sudo systemctl start riemann.service

if [[ "${INSTALL_RIEMANN_DASH}" = "True" ]]; then
	ctx logger info "Start script - Starting Riemann dash "
	sudo systemctl start riemann-dash.service
fi