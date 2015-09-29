// modules: gtk+-3.0
using Gtk;

public class LoginView : Window {

	private Entry server = new Entry();
	private Entry uname = new Entry();
	private Entry password = new Entry();
	private Label topLabel = new Label("Login to a Subsonic server");
	private LoginModel model;

	public LoginView(LoginModel model) {
		this.model = model;
		title = "Login";
		window_position = WindowPosition.CENTER;
		destroy.connect(Gtk.main_quit);
		set_default_size(400,250);
		//resizable = false;

		Box box = new Box(Orientation.VERTICAL, 20);
		box.margin_left = 65;
		box.margin_top = 25;
		box.margin_bottom = 25;
		this.add(box);
		topLabel.margin_right = 45;
		box.pack_start(topLabel, true, true,0);


		var serverBox = new Box(Orientation.HORIZONTAL, 2);
		var serverLabel = new Label("Server URL: ");
		serverBox.add(serverLabel);
		serverBox.add(server);
		box.pack_start(serverBox, false, false, 0);

		var nameBox = new Box(Orientation.HORIZONTAL, 2);
		var nameLabel = new Label("Username: ");
		nameBox.add(nameLabel);
		uname.max_length = 300;
		nameBox.add(uname);
		box.pack_start(nameBox, false, true, 0);

		var passBox = new Box(Orientation.HORIZONTAL, 2);
		passBox.add(new Label("Password: " ));
		password.set_visibility(false);
		passBox.add(password);
		box.pack_start(passBox, false, true, 0);
		
		var btnBox = new Box(Orientation.HORIZONTAL, 50);
		var cancelBtn = new Button.with_label("Cancel");
		cancelBtn.clicked.connect(close);
		cancelBtn.margin_left = 65;
		btnBox.add(cancelBtn);
		var loginBtn = new Button.with_label("Login");
		loginBtn.clicked.connect(on_login_clicked);
		btnBox.add(loginBtn);
		box.pack_start(btnBox, false, true, 0);

	}

	public void on_login_clicked() {
		var info = new string[3];
		info[0] = server.text;
		info[1] = uname.text;
		info[2] = password.text;
		model.try_login(info, true);
	}

	public void print_error(string e) {
		topLabel.set_markup("<b>Error:</b> %s".printf(e));
	}
	
	public void close_window() {
		Gtk.main_quit();
	}
		

}
