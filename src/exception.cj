/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * The file declars the Address class.
 */
package okhttp


/*
 * The class is HttpException inherited from RuntimeException
 * @author guo_tingtingtekla,luoyukai4
 * @since 0.29.3
 */
public open class HttpException <: Exception {
    /**
     * The Function is init constructor
     *
     * @param message of String
     * @since 0.29.3
     */
    public init(message: String) {
        super(message)
    }
    /*
     * The Function is getClassName
     *
     * @return Type of String
     * @since 0.29.3
     */
    protected override func getClassName(): String {
        return "HttpException"
    }
}

public class RouteException <: HttpException {
    private let firstException: HttpException
    private var lastException: HttpException

    public init(message: String, e: HttpException) {
        super(message)
        this.firstException = e
        this.lastException = e
    }

    public func getFirstConnectException(): HttpException {
        return firstException
    }

     public func getLastConnectException(): HttpException {
         return lastException
     }

     func addConnectException(e: HttpException) {
        lastException = e
     }
}

public class ConnectException <: HttpException {
    public let contain: Exception
    public init(message: String, e: Exception) {
        super(message)
        this.contain = e
    }
}

public class ProtocolException <: HttpException {
    public init(message: String) {
        super(message)
    }
}

public class H2ConnectionException <: HttpException {
    public init(message: String) {
        super(message)
    }
}

public class IllegalStateException <: Exception{
    public init(message: String) {
        super(message)
    }
}


public class NetException <: Exception {
    public init(message: String) {
        super(message)
    }
}