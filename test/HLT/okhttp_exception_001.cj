// 3rd_party_lib:okhttp/build/okhttp
// 3rd_party_lib:okhttp/ci_lib/cryptocj


from std import unittest.*
from std import unittest.testmacro.*
from std import io.*
from okhttp import okhttp.*
from std import time.*
from net import http.*
from std import socket.*
from encoding import url.*
from net import tls.*
from std import core.*
from std import collection.*

@Test
public class okhttp_exception_001{

    @TestCase
    func okhttp_exception_001(): Unit {
        
        var httpException = okhttp.HttpException("is a HttpException")
        var routeException = okhttp.RouteException("is a RouteException",httpException)
        routeException.getFirstConnectException()
        println("routeException.getFirstConnectException() :${routeException.getFirstConnectException().message}")
        @Assert(routeException.getFirstConnectException() is okhttp.HttpException , true)
        @Assert(routeException.getFirstConnectException().message , "is a HttpException")
        println("routeException.getLastConnectException() :${routeException.getLastConnectException().message}")
        @Assert(routeException.getLastConnectException() is okhttp.HttpException , true)
        @Assert(routeException.getLastConnectException().message , "is a HttpException")
    }

}

