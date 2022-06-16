package okhttp


public interface Callback {
    func onFailure(call: Call,  e: Exception): Unit

    func onResponse(call: Call,  response: Response): Unit
}