#!/usr/bin/env   python3
# -*- coding: utf-8 -*-
# crontab example: [* * * * * /usr/bin/python3 consul_deregister.py svc]

import sys
import logging
import requests

file_handler = logging.FileHandler(filename='/tmp/consul_deregister.log', encoding='utf-8')
logging.basicConfig(format="%(asctime)s [%(levelname)s] %(message)s", datefmt='%Y-%m-%d %H:%M:%S',
                    level=logging.INFO, handlers={file_handler})

def http_request(url, methods):
    if methods == 'get':
        try:
            responce = requests.get(url=url, timeout=5)
            res_data = responce.json()
        except Exception as e:
            logging.error(e)
    elif methods == 'put':
        try:
            responce = requests.put(url=url, timeout=5)
            res_data = responce.status_code
        except Exception as e:
            logging.error(e)
    return res_data

def get_node_ip(nodeName):
    node_url = "http://{}:{}/v1/catalog/node/{}".format(consul_host, consul_port, nodeName)
    node_data = http_request(node_url, 'get')
    node_ip = node_data["Node"].get('Address', '')
    return node_ip

def check_service(service_name):
    """
    检查服务
    :return:
    """
    res = {'critical':[], 'passing': []}
    chek_url = 'http://{}:{}/v1/health/checks/{}'.format(consul_host, consul_port, service_name)
    check_data = http_request(chek_url, 'get')
    if check_data:
        for i in check_data:
            if i['Status'] == 'critical':
                res['critical'].append(i['ServiceID'])
        return res
    else:
        logging.error("svc not found {}".format(service_name))
        return "svc not found {}".format(service_name)

if __name__ == '__main__':

    consul_host = '42.192.186.124'
    consul_port = '8500'

    service_name = sys.argv[1]
    data = check_service(service_name)

    if isinstance(data, dict):
        service = data.get('critical')
        for serviceId in service:
            deregister_url = 'http://{}:{}/v1/agent/service/deregister/{}'.format(consul_host, consul_port, serviceId)
            res = http_request(deregister_url, 'put')
            logging.info("request code: [{}]  delete exception {} node: [{}]".format(res, service_name, serviceId))
