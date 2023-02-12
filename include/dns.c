/*
 * Copyright (c) Huawei Technologies co., Ltd. 2022-2023. All Rights Resverd.
 * Description: openssl dns.c for Cangjie API
 */
#include<stdio.h>
#include<string.h>
#include<sys/types.h>
#include<sys/socket.h>
#include<netdb.h>
#include<netinet/in.h>
#include<arpa/inet.h>
#include<malloc.h>

int okhttp_SyscallGetAddrInfo(const char* node, const char* service,
                              const struct addrinfo* hints, struct addrinfo** res)
{
    return getaddrinfo(node, service, hints, res);
}

uint8_t* okhttp_SOCKET_ConvertAddrPtr(struct addrinfo* res)
{
    const int arraddrlen = 400;
    uint8_t tmpaddr[arraddrlen];
    int ip4cnt = 0;
    int ip6cnt = 0;
    const int ip4bytes = 5;
    const int ip6bytes = 17;

    for (struct addrinfo* cur = res; cur != NULL; cur = cur->ai_next) {
        if (cur->ai_addr == NULL) {
            continue;
        }

        if (ip4cnt * ip4bytes + ip6cnt * ip6bytes + 1 >
            arraddrlen - (cur->ai_family == AF_INET ? ip4bytes : ip6bytes)) {
            printf("Error: The number of IP exceeds the resolution range\n");
            return NULL;
        }

        if (cur->ai_family == AF_INET) {
            const int BYTE_WIDTH = 8;
            struct sockaddr_in* addr = (struct sockaddr_in*)cur->ai_addr;
            tmpaddr[ip4cnt * ip4bytes + ip6cnt * ip6bytes + 1] = ip4bytes - 1;
            uint32_t ip = addr->sin_addr.s_addr;
            for (int i = 1; i < ip4bytes; i++) {
                tmpaddr[ip4cnt * ip4bytes + ip6cnt * ip6bytes + i + 1] = ip & 0xFF;
                ip = ip >> BYTE_WIDTH;
            }
            ip4cnt++;
        }
		
        if (cur->ai_family == AF_INET6) {
            struct sockaddr_in6* addr = (struct sockaddr_in6*)cur->ai_addr;
            tmpaddr[ip4cnt * ip4bytes + ip6cnt * ip6bytes + 1] = ip6bytes - 1;
    #if defined __hm__ || __ohos__
            uint8_t* ip = addr->sin6_addr.__in6_union.__s6_addr;
    #else
			uint8_t* ip = addr->sin6_addr.__in6_u.__u6_addr8;
    #endif
			for (int i = 1; i < ip6bytes; i++) {
                tmpaddr[ip4cnt * ip4bytes + ip6cnt * ip6bytes + i + 1] = ip[i - 1];
            }
            ip6cnt++;
        }
    }

    if (ip4cnt != 0 || ip6cnt != 0) {
        tmpaddr[0] = ip4cnt + ip6cnt;
        uint8_t* ret = (uint8_t*)calloc(ip4cnt * ip4bytes + ip6cnt * ip6bytes + 1, sizeof(uint8_t));
        if (ret == NULL) {
            return NULL;
        }

        memcpy_s(ret, ip4cnt * ip4bytes + ip6cnt * ip6bytes + 1, tmpaddr, ip4cnt * ip4bytes + ip6cnt * ip6bytes + 1);
		// before: memcpy(ret, tmpaddr, ip4cnt * ip4bytes + ip6cnt * ip6bytes + 1)
        return ret;
    }

    return NULL;
}

uint8_t* okhttp_SOCKET_GetAddrInfo(uint8_t net, char* node)
{
    if (node == NULL || (net != IPPROTO_TCP && net != IPPROTO_UDP)) {
        return NULL;
    }
    struct addrinfo hints, *res = NULL;
    hints.ai_family = AF_UNSPEC;
    hints.ai_socktype = 0;
    hints.ai_flags = AI_PASSIVE | AI_ALL;
    hints.ai_protocol = net;
    hints.ai_canonname = NULL;
    hints.ai_addr = NULL;
    hints.ai_next = NULL;
    int i = 0;
    int r = okhttp_SyscallGetAddrInfo(node, NULL, &hints, &res);
    if (r != 0) {
        return NULL;
    }

    uint8_t* addr = okhttp_SOCKET_ConvertAddrPtr(res);
    freeaddrinfo(res);
    return addr;
}
