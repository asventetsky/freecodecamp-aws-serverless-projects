""" Url hash generator """

import hashlib
import logging

logging.getLogger().setLevel(logging.INFO)


def generate(original_url):
    """ Generates hash for short url """

    url_hash = hashlib.md5(original_url.encode()).hexdigest()

    logging.info('Generated hash for original url: %s', url_hash)

    return url_hash
