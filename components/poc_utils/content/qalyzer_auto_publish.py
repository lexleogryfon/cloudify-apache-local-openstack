#!/usr/bin/env python
import pika
import sys
import json
import time
import random


connection = pika.BlockingConnection(pika.ConnectionParameters( 'localhost',5672,'/', pika.PlainCredentials('{{ ctx.node.properties.rabbitmq_username }}', '{{ ctx.node.properties.rabbitmq_password }}')))
channel = connection.channel()

for x in range(0, 20000):

    time.sleep(random.randint(1, 100)/100)

    etime=int(time.time())

    line = {
        # Node instance id
        'node_id': '1234567890',

        # Node id
        'node_name': 'SomeNode',

        # Deployment id
        'deployment_id': 'SomeDep',

        # Metric name (e.g. cpu)
        'name': 'someName',

        # Sub-metric name (e.g. avg)
        'path': 'aPath',

        # The actual metric value
        'metric': random.randint(1, 100),

        # Metric unit
        'unit': 'Units',

        # Metric type (gauge, counter, etc...)
        'type': 'counter',

        # Host instance id
        'host': 'some.host',

        # The full metric name (
        # e.g. deployment_id.node_id.node_instance_id.metric)
        'service': random.sample(['objects', 'online_users', 'poc_service'],  1).pop() ,

        # epoch timestamp of the metric
        'time': etime ,
       }
    message = json.dumps(line) ;

    channel.basic_publish(exchange='riemann-monitoring',
                      routing_key='riemann',
                      body=message)

    print(" [x] Sent %r" % message)

#End Loop
