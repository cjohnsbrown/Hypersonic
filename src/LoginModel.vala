using Json;
using GLib.Environment;

public class LoginModel {
	
	private const string VERSION = "1.12.0";
	public LoginView view; 
	private Proxy proxy;
	private string server; 
	private string password; 
	private string uname;
	public bool loggedIn = false;
	
	public LoginModel(Proxy proxy) {
		try {
			this.proxy = proxy;
			this.view = new LoginView(this);
			var configFolder = File.new_for_path("../resources/");
			if (!configFolder.query_exists()) {
				configFolder.make_directory();
			}
			set_current_dir(configFolder.get_path());
			var configFile = File.new_for_path("hypersonic.conf");
			if (!configFile.query_exists()) {
				view.show_all();
				Gtk.main();
			} else {
				var valid = read_config(configFile);
				if (!valid) {
					view.show_all();
					Gtk.main();
				}
			}
		} catch (Error e) {
			stderr.printf("%s\n", e.message);
		}

	}


	public bool try_login(string[] info, bool encode) {
		server = info[0];
		uname = info[1];
		password = info[2];
		if (encode)
			password = toHex(info[2]);
		proxy.server = @"http://$server/rest/";
		proxy.parameters = @"u=$uname&p=enc:$password&v=$VERSION&c=Subparsonic&f=json";
		var pingJson = proxy.get_json("ping.view?");
		if (pingJson.contains("subsonic-response")) {
			var parser = new Parser();
			try {
				parser.load_from_data(pingJson, -1);
				var root = parser.get_root().get_object();
				var response = root.get_object_member("subsonic-response");
				var status = response.get_string_member("status");
				if (status == "failed") {
					var error = response.get_object_member("error");
					var msg = error.get_string_member("message");
					view.print_error(msg);
				} else { 
					loggedIn = true;
				   	if (encode)
				   		save_info();
				   	view.close_window();
				   	return true;
				}
			} catch (Error e) {
				stderr.printf("Error parsing json.\n");
				return false;
			}
		} else {
			view.print_error("Subsonic server could not be found");
			return false;
		}
		return false;
	}
	
	private void save_info() {
		try {
			var file = File.new_for_path("hypersonic.conf"); {
				var file_stream = file.create(FileCreateFlags.REPLACE_DESTINATION);
				var stream = new DataOutputStream(file_stream);
				stream.put_string(server + "\n");
				stream.put_string(uname + "\n");
				stream.put_string(password + "\n");
			}
		} catch (Error e) {
			stderr.printf("Error: %s\n", e.message);
		}
	}


	private bool read_config(File config) throws Error {
			var input = new DataInputStream(config.read());
			string line;
			var info = new string[3];
			int i=0;
			while ((line = input.read_line(null)) != null) {
				if (i > info.length)
					return false;
				info[i] = line;
				i++;
			}				
			return try_login(info, false);
	}
	

	private string toHex(string password) {
		var s = new StringBuilder();
		var bytes = password.data;
		for (int i=0; i<bytes.length;i++) {
			s.append("%02x".printf(bytes[i]));
		}
		return s.str;
	}

}


		
			
		
		


