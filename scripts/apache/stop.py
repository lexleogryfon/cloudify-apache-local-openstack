#!/usr/bin/env python
import subprocess

p = subprocess.Popen(['sudo', '/usr/bin/systemctl', 'stop', 'httpd'])
