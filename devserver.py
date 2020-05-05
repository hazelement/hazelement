
try:
    from urllib.parse import urlparse
except ImportError:
    from urlparse import urlparse

import click
from livereload import Server, shell
from pelican import Pelican
from pelican.settings import read_settings

@click.command()
@click.argument("pelicanconf", default='pelicanconf.py')
@click.argument("host", default='localhost')
@click.argument("port", default='8000')
def main(pelicanconf, host, port):
    settings = read_settings(pelicanconf)
    p = Pelican(settings)

    def compile():
        try:
            p.run()
        except SystemExit as e:
            print(e)

    compile()
    server = Server()
    server.watch(p.settings['PATH'], compile)
    server.watch(p.settings['THEME'], compile)
    server.watch(pelicanconf, compile)

    server.serve(host=host, port=port, root=settings['OUTPUT_PATH'])

if __name__ == "__main__":
    main()
