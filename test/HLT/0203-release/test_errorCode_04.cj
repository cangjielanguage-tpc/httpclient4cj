// 3rd_party_lib:httpclient4cj/build/httpclient4cj

from std import unittest.*
from std import unittest.testmacro.*
from std import io.*
from httpclient4cj import httpclient4cj.*
from std import time.*
from net import http.*
from std import socket.*
from encoding import url.*
from net import tls.*
from std import core.*

@Test
public class okhttp_errorCode_01{
    @TestCase
    func okhttp_fromHttp2_002(): Unit {
        var flag=0
        try{
             var re=ErrorCode.fromHttp2(23).getOrThrow()
        }catch(e:Exception){
             flag=1
        }
        @Assert(flag,1)
    }
}