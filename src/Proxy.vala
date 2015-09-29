// modules: libsoup-2.4
using Soup;

public class Proxy : Object {

	private Session session = new Session();
	private Message message;
	public string server;
	public string parameters;

	public Proxy() {
	}

	public string get_json(string apiCmd) {
		string url = server + apiCmd + parameters;
		message = new Message("GET", url);
		session.send_message(message);
		return (string)message.response_body.flatten().data;
	}


	
}
