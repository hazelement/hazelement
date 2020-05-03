try:
    from urllib.parse import urlparse
except ImportError:
    from urlparse import urlparse

from livereload import Server, shell
from pelican import Pelican
from pelican.settings import read_settings


def main(pelicanconf='pelicanconf.py', host='localhost', port='8000'):
    settings = read_settings('pelicanconf.py')
    p = Pelican(settings)

    def compile():
        try:
            p.run()
        except SystemExit as e:
            pass

    server = Server()
    server.watch(p.settings['PATH'], compile)
    server.watch(p.settings['THEME'], compile)
    server.watch('./pelicanconf.py', compile)

    server.serve(host=host, port=port, root=settings['OUTPUT_PATH'])

if __name__ == "__main__":
    main()in__":
    main().serve(host=host, port=port, root=settings['OUTPUT_PATH'])