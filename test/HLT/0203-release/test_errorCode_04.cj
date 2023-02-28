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