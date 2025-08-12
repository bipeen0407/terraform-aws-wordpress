import random
from typing import Dict


def lambda_edge_routing(event: Dict) -> Dict:
    """
    Lambda@Edge routing logic for CloudFront viewer requests.
    Routes traffic based on viewer country with weighted split:
      - Ireland (IE): 30% Ireland, 70% Singapore
      - Singapore (SG): 60% Singapore, 40% Ireland
      - Others: 50% Ireland, 50% Singapore
    """

    request = event['Records'][0]['cf']['request']
    headers = request['headers']

    # Get viewer country code (default to 'OTHER' if missing)
    country_code = headers.get('cloudfront-viewer-country', [{'value': 'OTHER'}])[0]['value'].upper()

    rand_val = random.random()

    # Define weighted routing logic
    if country_code == 'IE':
        region = 'Ireland' if rand_val < 0.3 else 'Singapore'
    elif country_code == 'SG':
        region = 'Singapore' if rand_val < 0.6 else 'Ireland'
    else:
        region = 'Ireland' if rand_val < 0.5 else 'Singapore'

    # TODO: Map region to origin domain names (replace with your actual ALB DNS names)
    origins = {
        'Ireland': 'irl-dev-alb-123456789.eu-west-1.elb.amazonaws.com',
        'Singapore': 'sgp-dev-alb-987654321.ap-southeast-1.elb.amazonaws.com'
    }

    # Update request to use the selected origin domain
    request['origin'] = {
        'custom': {
            'domainName': origins[region],
            'port': 443,
            'protocol': 'https',
            'path': '',
            'sslProtocols': ['TLSv1.2'],
            'readTimeout': 30,
            'keepaliveTimeout': 5,
            'customHeaders': {}
        }
    }
    request['headers']['host'] = [{'key': 'host', 'value': origins[region]}]

    return request
