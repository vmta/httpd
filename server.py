import os
from http.server import HTTPServer, CGIHTTPRequestHandler

def main():
    os.chdir( '/opt/html/.' )
    with HTTPServer( server_address = ('', 80), \
                     RequestHandlerClass=CGIHTTPRequestHandler ) as httpd:
        httpd.serve_forever()


if __name__ == "__main__":
    main()
