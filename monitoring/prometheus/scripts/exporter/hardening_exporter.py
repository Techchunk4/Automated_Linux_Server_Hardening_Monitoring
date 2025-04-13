from prometheus_client import start_http_server, Gauge
import psutil

# Custom metrics
HARDENING_GAUGES = {
    'ssh_protocol': Gauge('ssh_protocol_compliance', 'SSH Protocol 2 enforcement'),
    'ufw_status': Gauge('ufw_active', 'UFW firewall running status'),
}

def check_ufw():
    """Verify UFW is active"""
    try:
        return 1 if "Status: active" in subprocess.getoutput("ufw status") else 0
    except:
        return 0

if __name__ == '__main__':
    start_http_server(9000)
    while True:
        HARDENING_GAUGES['ssh_protocol'].set(check_ssh_compliance())
        HARDENING_GAUGES['ufw_status'].set(check_ufw())
        time.sleep(30)