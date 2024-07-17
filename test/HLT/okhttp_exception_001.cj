// 3rd_party_lib:httpclient4cj/build/httpclient4cj


import std.unittest.*
import std.unittest.testmacro.*
import std.io.*
import httpclient4cj
import httpclient4cj.*
import std.time.*
import net.http.*
import std.socket.*
import encoding.url.*
import net.tls.*
import std.core.*
import std.collection.*

@Test
public class okhttp_exception_001{

    @TestCase
    func okhttp_exception_001(): Unit {
        
        var httpException = httpclient4cj.HttpException("is a HttpException")
        var routeException = httpclient4cj.RouteException("is a RouteException",httpException)
        routeException.getFirstConnectException()
        println("routeException.getFirstConnectException() :${routeException.getFirstConnectException().message}")
        @Assert(routeException.getFirstConnectException() is httpclient4cj.HttpException , true)
        @Assert(routeException.getFirstConnectException().message , "is a HttpException")
        println("routeException.getLastConnectException() :${routeException.getLastConnectException().message}")
        @Assert(routeException.getLastConnectException() is httpclient4cj.HttpException , true)
        @Assert(routeException.getLastConnectException().message , "is a HttpException")
    }

}

