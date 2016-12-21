#!/usr/bin/env python3

from datetime import datetime
import docker
import etcd
import time

DEBUG = True
OPTION_TTL = 30

def debug(*args, **kwargs):
    if DEBUG:
        print(*args, flush=True, **kwargs)

def announce_service(etcd_client, hostname, container_name, ttl):
    key = '/services/{}/{}'.format(container_name, hostname)
    debug('Announcing service “{}”...'.format(key), end='')
    try:
        etcd_client.refresh(key, ttl=ttl)
        debug(' refreshed!')
    except etcd.EtcdKeyNotFound:
        debug(' refresh failed...', end='')
        etcd_client.write(key, None, ttl=ttl)
        debug(' written!')

if __name__ == '__main__':
    docker_client = docker.from_env(version='auto')
    hostname = docker_client.info()['Name']
    etcd_client = etcd.Client(host='172.17.0.1', port=2379)

    while True:
        timestamp = datetime.now()
        debug(timestamp)
        for container in docker_client.containers.list():
            announce_service(etcd_client, hostname, container.name, OPTION_TTL)
        timestamp_new = datetime.now()
        time.sleep(OPTION_TTL/2 - (timestamp_new - timestamp).seconds)
