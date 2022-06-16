package okhttp


public class Dispatcher{
    private var maxRequests: Int64 = 64
    private var maxRequestsPerHost: Int64 = 5
    private var readyAsyncCalls: ConcurrentQueue<AsyncCall>  =  ConcurrentQueue<AsyncCall>()
    private var runningAsyncCalls: ConcurrentQueue<AsyncCall>  =  ConcurrentQueue<AsyncCall>()
    private var runningSyncCalls: ConcurrentQueue<RealCall>  =  ConcurrentQueue<RealCall>()

    public func setMaxRequests(maxRequests: Int64): Unit {
        if (maxRequests < 1) {
          throw IllegalArgumentException("max < 1:${ maxRequests}")
        }
        //TODO

        promoteAndExecute();
    }
    public func executed( call: RealCall): Unit{
        runningSyncCalls.add(call);
    }

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

    func promoteAndExecute(): Bool {

        let executableCalls: ArrayList<AsyncCall> = ArrayList<AsyncCall>()
        var isRunning: Bool
        //TODO
         for (index in (0..executableCalls.size())) {
            let asyncCall: AsyncCall = executableCalls[index]
            if (runningAsyncCalls.toArrayList().size() >= maxRequests) {
                break; // Max capacity.
            }

            if (asyncCall.callsPerHost.load() >= maxRequestsPerHost) {
                continue; // Host max capacity.
            }
            readyAsyncCalls.toArrayList().remove(index)
            asyncCall.callsPerHost.fetchAdd(1)
            executableCalls.add(asyncCall)
            runningAsyncCalls.add(asyncCall)
         }

         isRunning = runningAsyncCalls.toArrayList().size() + runningSyncCalls.toArrayList().size() > 0
         for (asyncCall in executableCalls) {
            asyncCall.executeOn();
         }
         return isRunning
      }

}