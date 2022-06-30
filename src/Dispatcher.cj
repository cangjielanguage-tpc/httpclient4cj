/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * The file declars the Dispatcher class.
 */
package okhttp


/**
 * The class is Dispatcher
 * @author guo_tingtingtekla,luoyukai4
 * @since 0.29.3
 */
public class Dispatcher{
    /** var member mutex type is Monitor */
    public  var mutex: Monitor = Monitor()
    /* var member maxRequests type is Int64 */
    private var maxRequests: Int64 = 64
    /* var member maxRequestsPerHost type is Int64 */
    private var maxRequestsPerHost: Int64 = 5
    /* var member readyAsyncCalls type is ConcurrentQueue<AsyncCall> */
    private var readyAsyncCalls: ConcurrentQueue<AsyncCall>  =  ConcurrentQueue<AsyncCall>()
    /* var member runningAsyncCalls type is ConcurrentQueue<AsyncCall> */
    private var runningAsyncCalls: ConcurrentQueue<AsyncCall>  =  ConcurrentQueue<AsyncCall>()
    /* var member runningSyncCalls type is ConcurrentQueue<RealCall> */
    private var runningSyncCalls: ConcurrentQueue<RealCall>  =  ConcurrentQueue<RealCall>()

    /**
     * The Function is setMaxRequests
     *
     * @param maxRequests of Int64
     *
     * @return Type of Unit
     * @since 0.29.3
     */
    public func setMaxRequests(maxRequests: Int64): Unit {
        if (maxRequests < 1) {
          throw IllegalArgumentException("max < 1:${ maxRequests}")
        }
        //TODO

        promoteAndExecute();
    }
    /**
     * The Function is executed
     *
     * @param call of RealCall
     *
     * @return Type of Unit
     * @since 0.29.3
     */
    public func executed( call: RealCall): Unit{
        runningSyncCalls.add(call);
    }

    /*
     * The Function is finished
     *
     * @param calls of ConcurrentQueue<RealCall>
     * @param call of RealCall
     *
     * @return Type of Unit
     * @since 0.29.3
     */
    private func finished(calls: ConcurrentQueue<RealCall>, call: RealCall): Unit {
        synchronized (mutex) {
            for (index in 0..calls.size()) {
                if(refEq(call, calls.get(index))) {
                    calls.remove(index)
                }

            }
        }
       var isRunning: Bool = promoteAndExecute()
       if(!isRunning) {
        // TODO
       }
    }

    /*
     * The Function is finished
     *
     * @param call of RealCall
     *
     * @return Type of Unit
     * @since 0.29.3
     */
    func finished(call: RealCall): Unit {
        finished(runningSyncCalls, call)
    }

    /**
     * The Function is enqueue
     *
     * @param call of AsyncCall
     *
     * @return Type of Unit
     * @since 0.29.3
     */
    public func enqueue( call: AsyncCall): Unit{
        //TODO
        if(!call.get().forWebSocket) {
            match (findExistingCallWithHost(call.host())) {
                case Some(existingCall) => call.reuseCallsPerHostFrom(existingCall);
                case None => ()
            }
        }
        promoteAndExecute()
    }

    /*
     * The Function is findExistingCallWithHost
     *
     * @param host of String
     *
     * @return Type of Option<AsyncCall>
     * @since 0.29.3
     */
    private func findExistingCallWithHost(host: String): Option<AsyncCall> {
        for (existingCall in runningAsyncCalls) {
          if (existingCall.host().equals(host)) {
              return (existingCall)
          }
        }
        for (existingCall in readyAsyncCalls) {
          if (existingCall.host().equals(host)) {
              return existingCall
          }
        }
        return None
    }

    /*
     * The Function is promoteAndExecute
     *
     * @return Type of Bool
     * @since 0.29.3
     */
    func promoteAndExecute(): Bool {

        let executableCalls: ArrayList<AsyncCall> = ArrayList<AsyncCall>()
        var isRunning: Bool
        //TODO
         for (index in (0..readyAsyncCalls.size())) {
            let asyncCall: AsyncCall = executableCalls[index]
            if (runningAsyncCalls.toArrayList().size() >= maxRequests) {
                break; // Max capacity.
            }

            if (asyncCall.callsPerHost.load() >= maxRequestsPerHost) {
                continue; // Host max capacity.
            }
            readyAsyncCalls.toArrayList().remove(index)
            asyncCall.callsPerHost.fetchAdd(1)
            executableCalls.append(asyncCall)
            runningAsyncCalls.add(asyncCall)
         }

         isRunning = runningAsyncCalls.toArrayList().size() + runningSyncCalls.toArrayList().size() > 0
         for (asyncCall in executableCalls) {
            asyncCall.executeOn();
         }
         return isRunning
      }
}