libdns.so: ./include/dns.c
	gcc ./include/dns.c -fPIC -shared -o lib/libdns.so
