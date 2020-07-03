#include <stdio.h>
#include <WinSock2.h>

#define CLEAN_CONNECTION closesocket(pconn->srcsock); \
    WSACloseEvent(pconn->srcthandle); \
    closesocket(pconn->destsock); \
    WSACloseEvent(pconn->desthandle); \
    delete pconn

typedef struct _connection
{
    SOCKET srcsock;
    sockaddr_in srcaddr;
    HANDLE srcthandle;
    SOCKET destsock;
    sockaddr_in destaddr;
    HANDLE desthandle;
    BOOL tracedata;
}Connection;

typedef enum _direction
{
    TOTARGET = 0,
    FROMTARGET
}Direction;

VOID printhexdata(const char* data, int len)
{
    printf("hex data: ");

    for (int idx = 0; idx < len; ++idx)
    {
        printf("%02X ", *(data + idx));
    }

    printf("\n");
}

BOOL processsocketevents(SOCKET srcsock, SOCKET destsock, HANDLE handle, BOOL tracedata)
{
    WSANETWORKEVENTS events;
    if (WSAEnumNetworkEvents(srcsock, handle, &events) == SOCKET_ERROR)
    {
        printf("error: WSAEnumNetworkEvents failed with %d\n", WSAGetLastError());
        return FALSE;
    }

    if (events.lNetworkEvents & FD_READ) 
    {
        CHAR buffer[2048] = "";
        int bytes = recv(srcsock, buffer, sizeof buffer, 0);
        if (SOCKET_ERROR == bytes)
        {
            printf("function recv failed with %d on socket %d\n", WSAGetLastError(), srcsock);
            return FALSE;
        }
        else
        {
            printf("data received from socket: %d, len: %d\n", srcsock, bytes);
            if (tracedata)
            {
                printhexdata(buffer, bytes);
            }

            if (bytes > 0)
            {
                send(destsock, buffer, bytes, 0);
            }
        }
    }

    if (events.lNetworkEvents & FD_CLOSE) 
    {
        return FALSE;
    }

    return TRUE;
}


BOOL processsocketevents(Connection *pconn, Direction dir)
{
    BOOL result = TRUE;
    switch (dir)
    {
        case TOTARGET:
            result = processsocketevents(pconn->srcsock, pconn->destsock, pconn->srcthandle, pconn->tracedata);
            break;
        case FROMTARGET:
            result = processsocketevents(pconn->destsock, pconn->srcsock, pconn->desthandle, pconn->tracedata);
        default:
            break;
    }

    return result;
}


DWORD WINAPI portforward(void *pParam)
{
    Connection* pconn = (Connection*)pParam;
    printf("connection arrives: ip %s, port %u, sock %u\n", inet_ntoa(pconn->srcaddr.sin_addr),
            ntohs(pconn->srcaddr.sin_port), pconn->srcsock);
    
    printf("start connecting to remote host...\n");
    pconn->destsock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if (INVALID_SOCKET == pconn->destsock) 
    {
        printf("error: socket() failed with %d\n", WSAGetLastError());
        CLEAN_CONNECTION;
        return -1;
    }

    if (!connect(pconn->destsock, (SOCKADDR*)&pconn->destaddr, sizeof(pconn->destaddr)))
    {
        printf("connect successfully!\n");
    }
    else 
    {
        printf("connect failed with error with %d\n", WSAGetLastError());
        CLEAN_CONNECTION;
        return -2;
    }

    BOOL ready = TRUE;

    pconn->srcthandle = WSACreateEvent();
    if (WSAEventSelect(pconn->srcsock, pconn->srcthandle, FD_READ | FD_CLOSE) ==  SOCKET_ERROR)
    {
        printf("error: WSAEventSelect failed with %d\n", WSAGetLastError());
        WSACloseEvent(pconn->srcthandle);
        pconn->srcthandle = NULL;
        ready = FALSE;
    }

    pconn->desthandle = WSACreateEvent();
    if (WSAEventSelect(pconn->destsock, pconn->desthandle, FD_READ | FD_CLOSE) ==  SOCKET_ERROR)
    {
        printf("error: WSAEventSelect failed with %d\n", WSAGetLastError());
        WSACloseEvent(pconn->desthandle);
        pconn->desthandle = NULL;
        ready = FALSE;
    }

    if (!ready)
    {
        CLEAN_CONNECTION;
        return -3;
    }

    HANDLE handles[2];
    handles[0] = pconn->srcthandle;
    handles[1] = pconn->desthandle;

    BOOL exit = FALSE;
    while (!exit)
    {
        switch (WSAWaitForMultipleEvents(2, handles, FALSE, INFINITE, FALSE))
        {
            case WSA_WAIT_EVENT_0 + 1: // destination socket has signaled
                exit = !processsocketevents(pconn, FROMTARGET);
                break;

            case WSA_WAIT_EVENT_0: // source socket has signaled
                exit = !processsocketevents(pconn, TOTARGET);
                break;

            default:
                break;
        }
    }

    printf("connection exit normally\n");

    CLEAN_CONNECTION;
    return 0;
}

unsigned long gettargetaddress(const char* target, int retries)
{
    unsigned long addr = inet_addr(target);
    if (INADDR_NONE == addr)
    {
        while (retries-- > 0)
        {
            hostent *record = gethostbyname(target);
            if(record == NULL)
            {
                Sleep(1000);
                continue;
            }

            addr = (**(in_addr**)record->h_addr_list).S_un.S_addr;
            break;
        }

        if (retries <= 0)
        {
            printf("gettargetaddress: max retry reached, target: %s\n", target);
            exit(1);
        }

        printf("gettargetaddress: target: %s, ip: %u\n", target, addr);
    }

    return addr;
}

// for testing establishing a connection between hosts.
int main(int argc, char *argv[])
{
    if (argc < 4)
    {
        printf("--------------------------------------------------\n"
               "portforward forwards data from network to target host\n"
               "syntax: \n"
               "portforward [local port] [remote host] [remote port] [trace data] [retry host]\n"
               "    [local port] - listening port\n"
               "    [remote host] - target host name or ip address\n"
               "    [remote port] - target port\n"
               "    [trace data] - specifies whether the data from socket is printed,\n"
               "        0: do not print, default; 1: print it\n"
               "    [retry host] - specifies the max retries to get the ip address from host name,\n"
               "        this parameter only works when the host name is filled in parameter [remote host],\n"
               "        default 300 (5 minutes)\n"
               "--------------------------------------------------\n");
        return 0;
    }

    printf("parameters: listen port %s, host %s, port %s\n", argv[1], argv[2], argv[3]);
    
    u_short listenport = (u_short)atoi(argv[1]);
    u_short targetport = (u_short)atoi(argv[3]);
    char *targethost = argv[2];
    BOOL tracedata = argc > 4 ? atoi(argv[4]) : 0;
    int retries = argc > 5 ? atoi(argv[5]) : 300;

    printf("data from port [%d] will be forwarded to server [%s], port [%d]\n", listenport, targethost, targetport);

    //----------------------
    // Initialize Winsock
    WSADATA wsaData;
    if (NO_ERROR != WSAStartup(MAKEWORD(2,2), &wsaData))
    {
        printf("error: WSAStartup() failed with %d\n", WSAGetLastError());
        return -1;
    }

    sockaddr_in targetaddr;
    targetaddr.sin_family = AF_INET;
    targetaddr.sin_addr.s_addr = gettargetaddress(targethost, retries);
    targetaddr.sin_port = htons(targetport);


    //----------------------
    // Create a SOCKET
    SOCKET sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if (sock == INVALID_SOCKET) 
    {
        printf("error: socket() failed with %d\n", WSAGetLastError());
        WSACleanup();
        return -2;
    }

    //----------------------
    // The sockaddr_in structure specifies the address family,
    // IP address, and port for the socket that is being bound.
    sockaddr_in service;
    service.sin_family = AF_INET;
    service.sin_addr.s_addr = INADDR_ANY;
    service.sin_port = htons(listenport);
    if (bind(sock, (SOCKADDR*) &service, sizeof(service)) == SOCKET_ERROR)
    {
        printf("error: bind() failed with %d\n", WSAGetLastError());
        closesocket(sock);
        WSACleanup();
        return -3;
    }

    //----------------------
    // Listen for incoming connection requests 
    // on the created socket
    if (listen(sock, SOMAXCONN) == SOCKET_ERROR)
    {
        printf("error: listen on socket failed with %d\n", WSAGetLastError());
        closesocket(sock);
        WSACleanup();
        return -4;
    }

    printf("listening on socket...\n");
    while (true)
    {
        Connection* pconn = new Connection();
        memset(pconn, 0, sizeof Connection);
        pconn->tracedata = tracedata;
        memcpy(&pconn->destaddr, &targetaddr, sizeof pconn->destaddr);
        
        int addrLen = sizeof pconn->srcaddr;
        pconn->srcsock = accept(sock, (SOCKADDR*)&pconn->srcaddr, &addrLen);
        CloseHandle(CreateThread(NULL, 0, portforward, pconn, NULL, NULL));
        Sleep(10);
    }

    return 0;
}
